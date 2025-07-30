;;; tram-mode.el --- Major mode for Tram projects -*- lexical-binding: t; -*-

;;; Commentary:
;; A major mode for working with Tram projects, providing navigation
;; between handler and view files.

;;; Code:

(defgroup tram nil
  "Tram project navigation."
  :group 'programming)

(defun tram--extract-project-and-domain ()
  "Extract project name and domain from current file path.
Returns (project-name . domain) or nil if not in a Tram file."
  (when-let ((file-path (buffer-file-name)))
    (when (string-match (rx "src/" (group (+ (not "/"))) "/" 
                            (group (or "handlers" "views")) "/" 
                            (group (+ nonl)) "_" 
                            (group (or "handlers" "views")) 
                            ".clj" eos) file-path)
      (cons (match-string 1 file-path) (match-string 3 file-path)))))

(defun tram--build-file-path (project domain file-type)
  "Build file path for PROJECT, DOMAIN, and FILE-TYPE (handlers or views)."
  (format "src/%s/%s/%s_%s.clj" project file-type domain file-type))

(defun tram--find-project-root ()
  "Find the root directory of the Tram project."
  (locate-dominating-file default-directory "src"))

(defun tram--jump-to-file-type (target-type)
  "Jump to TARGET-TYPE (handlers or views) for the current domain."
  (if-let* ((proj-domain (tram--extract-project-and-domain))
            (project (car proj-domain))
            (domain (cdr proj-domain))
            (root (tram--find-project-root)))
      (let ((target-file (expand-file-name 
                         (tram--build-file-path project domain target-type) 
                         root)))
        (if (file-exists-p target-file)
            (find-file target-file)
          (message "Target file does not exist: %s" target-file)))
    (message "Not in a Tram handler or view file")))

(defun tram-jump-to-handler ()
  "Jump to the handler file for the current domain."
  (interactive)
  (tram--jump-to-file-type "handlers"))

(defun tram-jump-to-view ()
  "Jump to the view file for the current domain."
  (interactive)
  (tram--jump-to-file-type "views"))

(defun tram-jump-between-handler-and-view ()
  "Jump between handler and view files for the current domain."
  (interactive)
  (if-let* ((proj-domain (tram--extract-project-and-domain))
            (project (car proj-domain))
            (domain (cdr proj-domain))
            (root (tram--find-project-root)))
      (let* ((current-file (buffer-file-name))
             (is-handler (string-match-p "_handlers\\.clj$" current-file)))
        (if is-handler
            (tram-jump-to-view)
          (tram-jump-to-handler)))
    (message "Not in a Tram handler or view file")))

(defvar tram-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-j") 'tram-jump-between-handler-and-view)
    map)
  "Keymap for Tram mode.")

;;;###autoload
(define-minor-mode tram-mode
  "Minor mode for Tram project navigation."
  :lighter " Tram"
  :keymap tram-mode-map
  :group 'tram)

;;;###autoload
(add-hook 'clojure-mode-hook
          (lambda ()
            (when (and (buffer-file-name)
                       (string-match-p (rx "src/" (+ nonl) "/" (or "handlers" "views") "/") (buffer-file-name)))
              (tram-mode 1))))

(provide 'tram-mode)
