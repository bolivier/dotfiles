;;; comint-compose.el --- A persistent input composer for comint REPLs -*- lexical-binding: t; -*-

;; Author: Brandon Olivier <brandon@brandonolivier.com>
;; Version: 1.0.0
;; Package-Requires: ((emacs "26.1"))
;; Keywords: processes, convenience, comint

;; This file is not part of GNU Emacs.

;;; Commentary:

;; `comint-compose' gives a REPL -- any comint-derived one (a
;; `sql-interactive-mode' Postgres prompt, an inferior shell, a Python REPL,
;; ...) or a `vterm' terminal -- a small, persistent composer buffer that
;; lives in a window pinned to the bottom of the frame, beneath the REPL
;; itself -- think of CIDER's REPL buffer.
;;
;; You write your command in the composer with all your usual Emacs bindings,
;; then press C-c C-c.  The text is sent to the REPL, entered and evaluated
;; there (so it lands in the REPL's own input history), and -- unless you turn
;; off `comint-compose-clear-buffer-after-submit' -- the composer is cleared
;; ready for the next command.
;;
;; C-c C-p pulls the previous REPL input back into the composer so you can
;; edit and resubmit it; repeated presses walk further back, and C-c C-n walks
;; forward again.
;;
;; Usage:
;;   With point in a comint REPL or vterm buffer, call `comint-compose-open'.

;;; Code:

(require 'comint)
(require 'subr-x)
(require 'ring)

;; vterm is optional and only loaded on demand; declare its functions so the
;; byte-compiler stays quiet when it is not present.
(declare-function vterm-send-string "ext:vterm" (string &optional paste-p))
(declare-function vterm-send-return "ext:vterm" ())

;;;; Options

(defgroup comint-compose nil
  "Compose comint input in a dedicated bottom buffer."
  :group 'comint
  :prefix "comint-compose-")

(defcustom comint-compose-clear-buffer-after-submit t
  "When non-nil, clear the composer buffer after sending its contents.
When nil, the text is left in place after submitting so it can be
tweaked and resubmitted."
  :type 'boolean
  :group 'comint-compose)

(defcustom comint-compose-window-height 10
  "Height, in lines, of the composer window pinned at the bottom."
  :type 'integer
  :group 'comint-compose)

(defcustom comint-compose-default-major-mode #'text-mode
  "Major mode used in the composer buffer by default.
Consulted only when the source REPL's major mode has no entry in
`comint-compose-major-mode-alist'."
  :type 'function
  :group 'comint-compose)

(defcustom comint-compose-input-ring-size 64
  "How many sent inputs to remember for sources without their own history.
Used as the size of the composer-local history ring for non-comint
backends such as vterm, whose history lives in the inferior shell and is
not visible to Emacs."
  :type 'integer
  :group 'comint-compose)

(defcustom comint-compose-major-mode-alist
  '((sql-interactive-mode . sql-mode)
    (vterm-mode . sh-mode))
  "Alist mapping a source REPL major mode to the composer's major mode.
This lets the composer reuse the editing affordances (font-lock,
indentation, ...) of the language being typed.  Source modes not listed
fall back to `comint-compose-default-major-mode'."
  :type '(alist :key-type function :value-type function)
  :group 'comint-compose)

(defcustom comint-compose-setup-hook nil
  "Hook run in a composer buffer once it has been opened and configured.
Runs with the composer buffer current, its major mode active, and
`comint-compose--source-buffer' set.  Use it to attach extra tooling --
e.g. start an LSP client for schema-aware completion (see the Postgres
wiring in `postgres.el')."
  :type 'hook
  :group 'comint-compose)

;;;; State

(defvar-local comint-compose--source-buffer nil
  "The comint REPL buffer this composer sends its input to.")

(defvar-local comint-compose--history-index -1
  "Position in the source REPL's input ring while browsing history.
-1 means \"not currently browsing\".")

(defvar-local comint-compose--input-ring nil
  "Composer-local history ring for sources without their own (e.g. vterm).")

(defvar comint-compose-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") #'comint-compose-send)
    (define-key map (kbd "C-c C-p") #'comint-compose-previous)
    (define-key map (kbd "C-c C-n") #'comint-compose-next)
    (define-key map (kbd "C-c C-k") #'comint-compose-quit)
    map)
  "Keymap for `comint-compose-mode'.")

(define-minor-mode comint-compose-mode
  "Minor mode for a composer buffer attached to a comint REPL.
\\{comint-compose-mode-map}"
  :lighter " Compose"
  :keymap comint-compose-mode-map)

;;;; Helpers

(defun comint-compose--buffer-name (source)
  "Return the composer buffer name for SOURCE."
  (format "*compose: %s*" (buffer-name source)))

(defun comint-compose--major-mode-for (source)
  "Return the composer major mode to use for SOURCE."
  (or (cdr (assq (buffer-local-value 'major-mode source)
                 comint-compose-major-mode-alist))
      comint-compose-default-major-mode))

(defun comint-compose--source-or-error ()
  "Return the live source REPL buffer, or signal a `user-error'."
  (let ((source comint-compose--source-buffer))
    (unless (buffer-live-p source)
      (user-error "The REPL this composer was attached to is gone"))
    source))

(defun comint-compose--repl-buffer-p (&optional buffer)
  "Return non-nil if BUFFER (default current) is a supported REPL backend."
  (with-current-buffer (or buffer (current-buffer))
    (or (derived-mode-p 'comint-mode)
        (derived-mode-p 'vterm-mode))))

(defun comint-compose--send-to-source (source command)
  "Send COMMAND to the REPL in SOURCE and have it evaluated.
Dispatches on the REPL backend: comint buffers go through
`comint-send-input' (so the input joins their own history); vterm
buffers are driven with `vterm-send-string'/`vterm-send-return'."
  (with-current-buffer source
    (cond
     ((derived-mode-p 'vterm-mode)
      (vterm-send-string command t)
      (vterm-send-return))
     ((derived-mode-p 'comint-mode)
      (goto-char (point-max))
      (insert command)
      (comint-send-input))
     (t
      (user-error "Don't know how to send to a %s buffer" major-mode)))))

(defun comint-compose--history-ring ()
  "Return the history ring to browse, or nil if there is none yet.
Prefers the source's own `comint-input-ring'; for backends that don't
keep one (vterm), falls back to the composer-local ring of sent inputs."
  (let* ((source (comint-compose--source-or-error))
         (ring (buffer-local-value 'comint-input-ring source)))
    (if (and (ring-p ring) (not (ring-empty-p ring)))
        ring
      comint-compose--input-ring)))

;;;; Commands

;;;###autoload
(defun comint-compose-open ()
  "Open a composer buffer for the comint REPL or vterm in the current buffer.
The composer appears in a window pinned to the bottom of the frame and
stays attached to this REPL.  If it already exists it is simply
reselected."
  (interactive)
  (unless (comint-compose--repl-buffer-p)
    (user-error "Not in a comint or vterm REPL buffer"))
  (let* ((source (current-buffer))
         (mode (comint-compose--major-mode-for source))
         (buf (get-buffer-create (comint-compose--buffer-name source)))
         (fresh (zerop (buffer-size buf))))
    (with-current-buffer buf
      (when fresh
        (funcall mode))
      (comint-compose-mode 1)
      (setq comint-compose--source-buffer source)
      (setq comint-compose--history-index -1)
      (unless (ring-p comint-compose--input-ring)
        (setq comint-compose--input-ring
              (make-ring comint-compose-input-ring-size)))
      (setq header-line-format
            (substitute-command-keys
             "\\[comint-compose-send] send  \\[comint-compose-previous] prev  \
\\[comint-compose-next] next  \\[comint-compose-quit] hide")))
    (with-current-buffer buf
      (run-hooks 'comint-compose-setup-hook))
    (select-window
     (display-buffer-in-side-window
      buf `((side . bottom)
            (slot . 0)
            (window-height . ,comint-compose-window-height)
            (preserve-size . (nil . t)))))))

(defun comint-compose-send ()
  "Send the composer's contents to the source REPL and evaluate them.
For comint REPLs the text is entered through `comint-send-input', so it
is echoed and joins the REPL's own input history; for vterm it is pasted
and submitted, and remembered in the composer-local history ring.  Clears
the composer afterwards unless `comint-compose-clear-buffer-after-submit'
is nil."
  (interactive)
  (let ((source (comint-compose--source-or-error))
        (command (string-trim-right (buffer-string))))
    (when (string-empty-p command)
      (user-error "Nothing to send"))
    (unless (get-buffer-process source)
      (user-error "The REPL has no running process"))
    (comint-compose--send-to-source source command)
    ;; comint keeps its own input ring; for other backends (vterm) record
    ;; the command ourselves so C-c C-p can pull it back.
    (unless (buffer-local-value 'comint-input-ring source)
      (ring-insert comint-compose--input-ring command))
    (setq comint-compose--history-index -1)
    (when comint-compose-clear-buffer-after-submit
      (erase-buffer))))

(defun comint-compose--history-move (delta)
  "Replace the composer contents with an input DELTA steps away in history.
Positive DELTA moves toward older input."
  (let ((ring (comint-compose--history-ring)))
    (unless (and (ring-p ring) (not (ring-empty-p ring)))
      (user-error "No input history yet"))
    (let* ((len (ring-length ring))
           (index (max 0 (min (+ comint-compose--history-index delta) (1- len)))))
      (setq comint-compose--history-index index)
      (erase-buffer)
      (insert (ring-ref ring index)))))

(defun comint-compose-previous ()
  "Pull the previous REPL input into the composer for editing.
Repeat to walk further back through the history."
  (interactive)
  (comint-compose--history-move 1))

(defun comint-compose-next ()
  "Walk forward through the REPL input history pulled by \\[comint-compose-previous]."
  (interactive)
  (comint-compose--history-move -1))

(defun comint-compose-quit ()
  "Hide the composer window without sending anything."
  (interactive)
  (quit-window))

(provide 'comint-compose)
;;; comint-compose.el ends here
