;;; ../../code/dotfiles/configuration/doom/config/vanilla-emacs.el -*- lexical-binding: t; -*-


(when  (featurep :system 'macos)
  (setq mac-control-modifier 'control)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier  'super)
  (setq ns-function-modifier 'hyper))

(defmacro comment (&rest args)
  nil)

(setq! datetime-timezone 'US/Central)

(map! "C-r"     #'isearch-backward-regexp
      "C-s"     #'isearch-forward-regexp
      "C-x C-b" #'ibuffer
      "C-x ="   #'balance-windows
      "M-%"     #'query-replace-regexp
      "M-["     #'pop-global-mark
      "C-M-="   #'doom/increase-font-size
      "C-M--"   #'doom/decrease-font-size
      "M-j"     #'bso/join-line
      "M-z"     #'zap-up-to-char
      "M-Z"     #'zap-to-char
      "M-\\" #'bso/delete-horizontal-space-dwim
      :leader :prefix "o"
      "d" #'switch-to-or-create-postgres-buffer)

(global-subword-mode 1)
(defun save-all () (save-some-buffers t))
(add-hook! focus-out #'save-all)

(defun bso/open-line-indent ()
  "Opening a newline and moving text before indentation sucks ass.
This fixes that with better behavior."
  (interactive)
  (open-line 1)
  (indent-for-tab-command)
  (save-excursion
    (forward-line 1)
    (indent-for-tab-command)))

(defun bso/join-line ()
  (interactive)
  (save-excursion
    (end-of-line)
    (delete-char 1)
    (just-one-space)
    (end-of-line)
    (delete-horizontal-space)))

(defun bso/yank-buffer-file-name ()
  "Yank the buffer file name into the clipboard"
  (interactive)
  (kill-new (buffer-file-name)))

(defun window-split-toggle ()
  "Toggle between horizontal and vertical split with two windows."
  (interactive)
  (if (> (length (window-list)) 2)
      (error "Can't toggle with more than 2 windows!")
    (let ((func (if (window-full-height-p)
                    #'split-window-vertically
                  #'split-window-horizontally)))
      (delete-other-windows)
      (funcall func)
      (save-selected-window
        (other-window 1)
        (switch-to-buffer (other-buffer))))))

(defun bso/delete-horizontal-space-dwim ()
  "DWIM version of `delete-horizontal-space`.

- If between words (whitespace on both sides), reduce to 1 space.
- If just leading/trailing space, delete all.
- If no space, do nothing."
  (interactive)
  (let ((start (point))
        (before (char-before))
        (after (char-after)))
    (cond
     ;; If surrounded by space, reduce to 1 space
     ((and (eq (char-syntax before) ?\ )
           (eq (char-syntax after) ?\ ))
      (just-one-space))

     ;; If only space before, delete it
     ((eq (char-syntax before) ?\ )
      (skip-chars-backward " \t")
      (delete-region (point) start))

     ;; If only space after, delete it
     ((eq (char-syntax after) ?\ )
      (skip-chars-forward " \t")
      (delete-region start (point)))

     ;; Otherwise do nothing
     (t (message "No horizontal space to delete")))))

(defun bso/insert-key-description ()
  "Read a key sequence interactively, and insert its human-readable form at point.
For example, pressing C-x C-s will insert the string \"C-x C-s\"."
  (interactive)
  (let ((keys (read-key-sequence "Press key sequence: ")))
    (insert "\"" (key-description keys) "\"")))

(setq initial-major-mode 'lisp-interaction-mode)

(after! paredit
  (add-hook! (emacs-lisp-mode lisp-interaction-mode) #'enable-paredit-mode))

(after! eros
  (defun bso/elisp-conditional-eval ()
    "Eval region if active, forward sexp if at opening paren,
last sexp if at closing paren."
    (interactive)
    (save-excursion
      (cond
       ((use-region-p) (eval-region (mark) (point)))
       ((looking-at (rx (any "({["))) (paredit-forward) (eros-eval-last-sexp nil))
       ((looking-back (rx (any "]})"))) (eros-eval-last-sexp nil))
       (t (message "Could not find anything to eval.")))))

  (map! :map emacs-lisp-mode-map
        "C-c C-c" #'eros-eval-defun
        "M-e" #'bso/elisp-conditional-eval
        "M-E" #'eval-buffer

        :map lisp-interaction-mode-map
        "C-c C-c" #'eros-eval-defun
        "M-e" #'bso/elisp-conditional-eval
        "M-E" #'eval-buffer))
