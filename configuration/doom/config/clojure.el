;;; ../../code/dotfiles/configuration/doom/config/clojure.el -*- lexical-binding: t; -*-

(use-package! cider
  :init
  (setq! lsp-clojure-server-command '("clojure-lsp"))
  (setq-default cider-clojure-cli-aliases ":dev:test")
  (setq cider-clojure-cli-aliases ":dev:test")
  (setq! clojure-toplevel-inside-comment-form t)

  :config


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



  (add-hook! clojure-mode
    (smartparens-strict-mode -1)
    (smartparens-mode -1)
    #'enable-paredit-mode)

  (defun bso/cider-restart ()
    (interactive)
    (save-some-buffers t)
    (cider-interactive-eval
     "(ns user) (require '[integrant.repl :as ir]) (ir/reset)"))

  (defun bso/cider-inside-let-p ()
    "Check if I'm immediately inside a let binding"
    (interactive)
    (condition-case err
        (save-excursion
          (paredit-backward-up 2)
          (looking-at "(let"))
      (error nil)))

  (defun bso/cider-def-var ()
    "Read the previous sexp and define it as (def NAME <sexp>) in Clojure using CIDER."
    (interactive)
    (save-excursion
      (let ((sexp (progn
                    (backward-sexp)
                    (thing-at-point 'sexp t)))
            (name (if (bso/cider-inside-let-p)
                      (progn
                        (backward-sexp)
                        (thing-at-point 'symbol))
                    (read-string "Var name: ")
                    )))
        (cider-interactive-eval
         (format "(def %s %s)" name sexp)))))

  (map! :map cider-mode-map

        "C-c l e v" #'bso/cider-def-var

        :map clojure-mode-map
        "C-c C-r s e" #'cljr-expand-let
        "C-c C-r U" #'clojure-unwind-all)

  ;; Keeps perf good


  (defun save-clojure-buffer (&rest x)
    (save-buffer 0))

  (advice-add 'cider-eval-buffer :before #'save-clojure-buffer)

  (defun bso-cider/conditional-eval ()
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

  (map!
   :map paredit-mode-map
   "M-<backspace>" 'paredit-backward-kill-word
   "d" 'self-insert-command
   "DEL" 'paredit-backward-delete
   :n ">" #'paredit-forward-slurp-sexp
   :n "<" #'paredit-forward-barf-sexp
   :nv "D" #'paredit-kill

   (:map cider-mode-map
    :leader :prefix "me"
    :n "f" #'cider-eval-defun-at-point
    :n "v" #'cider-eval-last-sexp-in-context
    :n "p" #'cider-pprint-eval-last-sexp
    :n "P" #'cider-eval-last-sexp-and-replace)

   :mode cider-repl-mode
   "<up>"   #'cider-repl-previous-input
   "<down>" #'cider-repl-next-input
   "C-c o"  #'cider-repl-clear-buffer

   :map cider-mode-map
   "<f4>" #'bso/cider-restart
   "M-e" #'bso-cider/conditional-eval
   "M-E" #'cider-eval-buffer

   :leader :prefix "l"
   "e a" #'bso/cider-restart)

  (defun skip-to-closing-if-at-opening (f &rest args)
    (save-excursion
      (when (looking-at (rx (any "({[")))
        (paredit-forward))
      (apply f args)))

  (advice-add 'cider-pprint-eval-last-sexp :around #'skip-to-closing-if-at-opening)

  (defun my/cider-show-result-in-cider-result-buffer (value)
    "Show eval result VALUE in *cider-result*, replacing its contents."
    (when (get-buffer-window "*cider-result*")
      (let ((buf (get-buffer-create "*cider-result*")))
        (with-current-buffer buf
          (let ((inhibit-read-only t))
            (erase-buffer)
            (insert value)
            (goto-char (point-min))))
        ;; (display-buffer buf)
        )))

  (defun my/cider-wrap-result-handler (orig-fn &rest args)
    "Override result handler to always show in *cider-result* buffer."
    (let ((result (apply orig-fn args)))
      (my/cider-show-result-in-cider-result-buffer result)))

  ;; (advice-remove 'cider--display-interactive-eval-result #'my/cider-wrap-result-handler)


  (add-hook! cider-repl-mode #'paredit-mode))
