;;; ../../code/dotfiles/configuration/doom/config/web.el -*- lexical-binding: t; -*-

(comment
 (use-package! typescript-mode
   :config
   (defun bso/toggle-js-async-fn ()
     "Toggle between async and non async JS functions.

Calls sp-backwards-up-sexp until at what looks like a JS function
and them either inserts `async' or deletes it.

The implementation is kinda sloppy, but it works fine for now.

I limited nesting to 10, if that's too few, I can implement by
checking the last known position of the point.'"
     (interactive)
     (cl-flet* ((looking-at-js-function? (lambda ()
                                           (or
                                            (looking-back "=> ")

                                            (save-excursion
                                              (backward-word 3)
                                              (looking-at "function"))

                                            (save-excursion
                                              (backward-word 3)
                                              (looking-at "function")))))

                (move-to-anon-fn-init (lambda ()
                                        (sp-backward-sexp 1)
                                        (unless (looking-at "(")
                                          (web-mode-backward-sexp 1))))

                (move-to-function-fn-init (lambda ()
                                            (sp-backward-sexp 3)
                                            (unless (looking-at "function")
                                              (web-mode-backward-sexp 1))))

                (move-to-fn-init (lambda ()
                                   (if (looking-back "=> ")
                                       (move-to-anon-fn-init)
                                     (move-to-function-fn-init)))))
       (save-excursion
         (let* ((i 0))
           (while (and (not (looking-at-js-function?))
                       (< i 10))
             (setq i (+ 1 i))
             (sp-backward-up-sexp))
           (move-to-fn-init))
         (if (save-excursion
               (backward-word 1)
               (looking-at
                (rx "async " anychar)))
             (progn
               (backward-word 1)
               (kill-word 1)
               (if (looking-at " function")
                   (delete-horizontal-space)
                 (just-one-space)))
           (insert "async ")))))

   (add-hook! (typescript-tsx-mode typescript-mode rjsx-mode)
              'prettier-mode
              'turn-on-smartparens-strict-mode
              (emmet-mode -1))
   (map! :map (typescript-mode typescript-tsx-mode-map
                               js2-mode)
         "C-c c f" #'bso/toggle-js-async-fn)


   (map! :map general-override-mode-map
         "C-c c f" nil)
   ))

(comment
 (defun +web/indent-or-yas-or-emmet-expand ()
   "Do-what-I-mean on TAB.

Invokes `indent-for-tab-command' if at or before text bol, `yas-expand' if on a
snippet, or `emmet-expand-yas'/`emmet-expand-line', depending on whether
`yas-minor-mode' is enabled or not."
   (interactive)
   (call-interactively
    (cond ((or (<= (current-column) (current-indentation))
               (not (eolp))
               (not (or (memq (char-after) (list ?\n ?\s ?\t))
                        (eobp))))
           #'indent-for-tab-command)
          ((yas--templates-for-key-at-point)
           #'yas-expand)

          #'emmet-expand-yas))))

(comment
 (use-package! rjsx-mode
   :init
   (add-hook! rjsx-mode 'prettier-mode
     (emmet-mode -1))))

(comment
 (use-package! json-mode
   :init
   (add-hook! json-mode 'prettier-mode)))


(comment (use-package! js2-mode
           :config
           (map! :map js2-mode-map
                 "M-." nil)))

(comment
 (use-package! yaml-pro
   :after yaml-mode
   :hook (yaml-mode . yaml-pro-mode)
   :config
   (add-hook! yaml-mode #'turn-on-smartparens-strict-mode)
   (map! :map yaml-pro-mode-map
         [remap imenu] #'yaml-pro-jump
         :n "zc" #'yaml-pro-fold-at-point
         :n "zo" #'yaml-pro-unfold-at-point
         :n "gk" #'yaml-pro-prev-subtree
         :n "gj" #'yaml-pro-next-subtree
         :n "gK" #'yaml-pro-up-level
         :n "M-k" #'yaml-pro-move-subtree-up
         :n "M-j" #'yaml-pro-move-subtree-down)))



(comment
 (add-hook! ruby-mode smartparens-strict-mode))

(set-file-template! "\\.test\\.tsx?"   :mode 'typescript-tsx-mode
  :trigger "__test.js")
