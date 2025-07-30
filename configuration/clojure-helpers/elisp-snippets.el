;; Disabled for performance reasons
(setq! clojure-toplevel-inside-comment-form t)
(setq-default cider-clojure-cli-aliases ":dev:test:xtdb")
(setq cider-clojure-cli-aliases ":dev:test:xtdb")

(add-hook! clojure-mode
           'turn-off-smartparens-strict-mode
           'turn-off-smartparens-mode
           'enable-paredit-mode)

(defun bso/cider-restart ()
  "Restarts your application with fully reloaded code."
  (interactive)
  (save-some-buffers t)
  (cider-interactive-eval
   "(ns user) (require '[integrant.repl :as ir]) (ir/reset)"))

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
