;;; ../../code/dotfiles/configuration/doom/config/clojure.el -*- lexical-binding: t; -*-

(after! clojure-mode
  (setq! lsp-clojure-server-command '("clojure-lsp"))
  (setq! clojure-toplevel-inside-comment-form t)

  (map! :map clojure-mode-map
        "C-c C-r s e" #'cljr-expand-let
        "C-c C-r U" #'clojure-unwind-all))

(add-hook! clojure-mode
  (require 'apheleia)
  (setf (alist-get 'zprint apheleia-formatters)
        '("zprint"))
  (setf (alist-get 'clojure-mode apheleia-mode-alist) 'zprint
        (alist-get 'clojure-ts-mode apheleia-mode-alist) 'zprint)

  ;; add testing template -- this might need to be after clj-refactor
  (setq cljr-clojure-test-declaration "[clojure.test :refer [deftest is]]")
  )

(after! cider
  (setq-default cider-clojure-cli-aliases ":dev:test")
  (setq cider-clojure-cli-aliases ":dev:test")

  (add-hook! cider-connected-hook
    (when (and (bound-and-true-p persp-mode)
               (cider-current-repl))
      (persp-add-buffer (cider-current-repl))))

  (map! :map cider-mode-map
        "C-c l e v" #'bso/cider-def-var
        "<f4>" #'bso/cider-restart
        "M-e" #'bso/cider-conditional-eval

        "M-E" #'cider-eval-buffer

        :mode cider-repl-mode
        "<up>"   #'cider-repl-previous-input
        "<down>" #'cider-repl-next-input
        "C-c o"  #'cider-repl-clear-buffer)

  ;; (advice-remove 'cider-eval-buffer #'save-buffer)
  (advice-add 'cider-pprint-eval-last-sexp :around #'skip-to-closing-if-at-opening)

  (defun clojure-project-root-path (&optional dir-name)
    "Overridden by me in the config.

Return the absolute path to the project's root directory.

Use `default-directory' if DIR-NAME is nil.
Return nil if not inside a project."
    (let* ((dir-name (or dir-name default-directory))
           (choices (delq nil
                          (mapcar (lambda (fname)
                                    (locate-dominating-file dir-name fname))
                                  clojure-build-tool-files))))
      (when (> (length choices) 0)
        (car (sort choices)))))

  (defun bso/cider-restart ()
    (interactive)
    (save-some-buffers t)
    (cider-interactive-eval
     "(ns user)
      (require '[integrant.repl :as ir]
               '[clojure.tools.namespace.repl :refer [refresh-all]])
      (do (refresh-all)
          (ir/reset-all))"))

  (defun bso/cider-inside-let-like-p ()
    "Check if I'm immediately inside a let binding"
    (interactive)
    (condition-case err
        (save-excursion
          (paredit-backward-up 2)
          (or
           (looking-at "(let")
           (looking-at "(loop")))
      (error nil)))

  (defun bso/cider-def-var () "Read the previous sexp and define
it as (def NAME <sexp>) in Clojure using CIDER."
         (interactive)
         (save-excursion
           (let* ((sexp (save-excursion
                          (paredit-backward 1)
                          (thing-at-point 'sexp t))))

             (cond
              ((save-excursion
                 (paredit-backward 2)
                 (looking-at "{:keys"))
               (progn
                 (paredit-backward 2)
                 (paredit-forward-down 2)
                 (let ((names (list)))
                   (while (not (looking-at "}"))
                     (push (thing-at-point 'symbol t) names)
                     (paredit-forward)
                     (forward-char 1))
                   (--map (cider-interactive-eval (format "(def %s (:%s %s))" it it sexp)) names))))

              (t    (let ((name (if (bso/cider-inside-let-like-p)
                                    (progn
                                      (paredit-backward 2)
                                      (thing-at-point 'symbol t))
                                  (read-string "Var name: "))))
                      (cider-interactive-eval (format "(def %s %s)" name sexp))))))))


  (defun save-clojure-buffer (&rest x)
    (save-buffer 0))

  (defun bso/cider-conditional-eval ()
    "Evaluate the region as elisp when the region is active.
Alternately eval the last sexp if the char before point is `)'.
Otherwise move forward sentence, like normal"
    (interactive)
    (let ((beg (mark))
          (end (point)))
      (save-excursion
        (cond
         ((use-region-p) (cider-eval-region beg end))
         ((looking-at (rx (any "({["))) (paredit-forward) (cider-eval-last-sexp nil))

         ((looking-back (rx (any "]})"))) (cider-eval-last-sexp nil))
         (t (message "Could not find anything to eval."))))))



  (defun skip-to-closing-if-at-opening (f &rest args)
    (save-excursion
      (when (looking-at (rx (any "({[")))
        (paredit-forward))
      (apply f args))))
