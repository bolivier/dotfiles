(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ignored-local-variable-values
   '((eval define-clojure-indent (p/defprotocol+ '(1 (:defn)))
      (p/def-map-type '(2 nil nil (:defn))) (p/deftype+ '(2 nil nil (:defn))))
     (eval put 'p/def-map-type 'clojure-doc-string-elt 2)
     (eval put 'p/defprotocol+ 'clojure-doc-string-elt 2)
     (eval put 'm/defmulti 'clojure-doc-string-elt 2)
     (eval put 'm/defmethod 'clojure-doc-string-elt 3)
     (column-enforce-column . 120)
     (elisp-lint-indent-specs (if-let* . 2) (when-let* . 1) (let* . defun)
      (nrepl-dbind-response . 2) (cider-save-marker . 1)
      (cider-propertize-region . 1) (cider-map-repls . 1) (cider--jack-in . 1)
      (cider--make-result-overlay . 1) (insert-label . defun)
      (insert-align-label . defun) (insert-rect . defun) (cl-defun . 2)
      (with-parsed-tramp-file-name . 2) (thread-first . 0) (thread-last . 0)
      (transient-define-prefix . defmacro) (transient-define-suffix . defmacro))
     (checkdoc-package-keywords-flag)))
 '(package-selected-packages '(vc-jj))
 '(projectile-create-missing-test-files t)
 '(safe-local-variable-values '((cider-clojure-cli-aliases . ":test:dev"))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'upcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
