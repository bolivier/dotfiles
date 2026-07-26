;;; tram-mode.el --- Minor mode for Tram projects -*- lexical-binding: t; -*-

;;; Commentary:
;; Navigation for projects built with the Tram framework, which lays source
;; out as src/<package>/{handlers,views,models,concerns,components}/ with a
;; tram.edn at the project root.

;;; Code:

(require 'subr-x)
(require 'seq)

(defgroup tram nil
  "Support for the Tram framework."
  :group 'programming)

(defcustom tram-project-file "tram.edn"
  "File whose presence marks the root of a Tram project."
  :type 'string
  :group 'tram)

(defconst tram--layers
  '((handlers . "_handlers")
    (views . "_views")
    (components . "_components")
    (models . "")
    (concerns . ""))
  "Alist of Tram source layer to the filename suffix files in it carry.")

(defun tram-project-root (&optional dir)
  "Return the Tram project root at or above DIR, or nil when there is none."
  (when-let ((root (locate-dominating-file (or dir default-directory)
                                           tram-project-file)))
    (file-name-as-directory (expand-file-name root))))

(defun tram--require-root ()
  (or (tram-project-root)
      (user-error "Not inside a Tram project (no %s found)" tram-project-file)))

(defun tram--sole-package (root)
  (let ((src (expand-file-name "src" root)))
    (when (file-directory-p src)
      (car (seq-filter (lambda (name)
                         (file-directory-p (expand-file-name name src)))
                       (directory-files src nil directory-files-no-dot-files-regexp))))))

(defun tram--package (root)
  "Return the source package directory name for the project at ROOT."
  (or (when-let* ((file (buffer-file-name))
                  (rel (file-relative-name file root)))
        (when (string-match (rx bos "src/" (group (+ (not (any "/")))) "/") rel)
          (match-string 1 rel)))
      (tram--sole-package root)
      (user-error "Cannot determine the source package under %ssrc" root)))

(defun tram--location (&optional file)
  "Return (LAYER . DOMAIN) for FILE, or nil when it is not in a Tram layer."
  (when-let* ((file (or file (buffer-file-name)))
              (root (tram-project-root))
              (rel (file-relative-name file root)))
    (when (string-match (rx bos "src/" (+ (not (any "/"))) "/"
                            (group (+ (not (any "/")))) "/"
                            (group (+ (not (any "/")))) ".clj" eos)
                        rel)
      (let* ((layer (intern (match-string 1 rel)))
             (base (match-string 2 rel))
             (suffix (alist-get layer tram--layers)))
        (when suffix
          (cons layer (string-remove-suffix suffix base)))))))

(defun tram--path (root package layer domain)
  (expand-file-name (format "src/%s/%s/%s%s.clj"
                            package layer domain (alist-get layer tram--layers))
                    root))

(defun tram--domains (root package layer)
  (let ((dir (expand-file-name (format "src/%s/%s" package layer) root))
        (suffix (alist-get layer tram--layers)))
    (when (file-directory-p dir)
      (mapcar (lambda (name)
                (string-remove-suffix suffix (file-name-base name)))
              (directory-files dir nil (rx ".clj" eos))))))

(defun tram--read-domain (root package layer)
  (let ((domains (tram--domains root package layer)))
    (unless domains
      (user-error "No %s in this project" layer))
    (completing-read (format "%s: " layer) domains nil t)))

(defun tram--hyphenate (name)
  (replace-regexp-in-string "_" "-" name))

(defun tram--insert-ns (package layer domain)
  (when (zerop (buffer-size))
    (insert (format "(ns %s.%s.%s%s)\n"
                    (tram--hyphenate package)
                    layer
                    (tram--hyphenate domain)
                    (tram--hyphenate (alist-get layer tram--layers))))))

(defun tram--visit (layer domain)
  (let* ((root (tram--require-root))
         (package (tram--package root))
         (path (tram--path root package layer domain)))
    (cond
     ((file-exists-p path) (find-file path))
     ((y-or-n-p (format "Create %s? " (file-relative-name path root)))
      (make-directory (file-name-directory path) t)
      (find-file path)
      (tram--insert-ns package layer domain))
     (t (user-error "No %s for %s" layer domain)))))

(defun tram--goto (layer prompt)
  (let* ((root (tram--require-root))
         (package (tram--package root))
         (domain (or (and (not prompt) (cdr (tram--location)))
                     (tram--read-domain root package layer))))
    (tram--visit layer domain)))

(defun tram-jump-between-handler-and-view ()
  "Jump between the handler and view for the domain of the current file."
  (interactive)
  (pcase (tram--location)
    (`(handlers . ,domain) (tram--visit 'views domain))
    (`(views . ,domain) (tram--visit 'handlers domain))
    (`(,_ . ,domain) (tram--visit 'handlers domain))
    (_ (user-error "Not in a Tram source layer"))))

(defun tram-find-handler (&optional prompt)
  "Visit the handler for the current domain, or PROMPT for one."
  (interactive "P")
  (tram--goto 'handlers prompt))

(defun tram-find-view (&optional prompt)
  "Visit the view for the current domain, or PROMPT for one."
  (interactive "P")
  (tram--goto 'views prompt))

(defun tram-find-model (&optional prompt)
  "Visit the model for the current domain, or PROMPT for one."
  (interactive "P")
  (tram--goto 'models prompt))

(defun tram-find-concern (&optional prompt)
  "Visit the concern for the current domain, or PROMPT for one."
  (interactive "P")
  (tram--goto 'concerns prompt))

(defun tram-find-routes ()
  "Visit the project's routes namespace."
  (interactive)
  (let ((root (tram--require-root)))
    (find-file (expand-file-name (format "src/%s/routes.clj" (tram--package root))
                                 root))))

(defvar tram-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-j") #'tram-jump-between-handler-and-view)
    (define-key map (kbd "C-c t j") #'tram-jump-between-handler-and-view)
    (define-key map (kbd "C-c t h") #'tram-find-handler)
    (define-key map (kbd "C-c t v") #'tram-find-view)
    (define-key map (kbd "C-c t m") #'tram-find-model)
    (define-key map (kbd "C-c t c") #'tram-find-concern)
    (define-key map (kbd "C-c t r") #'tram-find-routes)
    map)
  "Keymap for `tram-mode'.")

;;;###autoload
(define-minor-mode tram-mode
  "Minor mode for navigating Tram projects."
  :lighter " Tram"
  :keymap tram-mode-map
  :group 'tram)

;;;###autoload
(defun tram-mode-maybe-enable ()
  "Enable `tram-mode' when this buffer's file lives in a Tram project."
  (when (and (buffer-file-name) (tram-project-root))
    (tram-mode 1)))

(provide 'tram-mode)
;;; tram-mode.el ends here
