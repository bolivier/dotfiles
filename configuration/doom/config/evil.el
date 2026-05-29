;;; ../../code/dotfiles/configuration/doom/config/evil.el -*- lexical-binding: t; -*-

(after! evil
  ;; kj won't work without this
  (evil-escape-mode)

  (map!
   :i "C-w j" #'evil-window-down
   :i "C-w k" #'evil-window-up
   :i "C-w h" #'evil-window-left
   :i "C-w l" #'evil-window-right)

  (map!
   :after vterm
   :map vterm-mode-map
   "C-h" #'evil-window-left
   "C-j" #'evil-window-down
   "C-k" #'evil-window-up
   "C-l" #'evil-window-right))

(after! evil-escape
  (setq evil-escape-key-sequence "kj"))

(after! evil-snipe
  (setq! evil-snipe-scope 'visible))

(after! (evil paredit)
  (defun bso/evil-change-line-in-paredit ()
    "Use `paredit-kill' then change into insert mode. Basically just a
smarter version of the regular behavior"
    (interactive)
    (paredit-kill)
    (evil-insert 1)))

(after! (evil cider)

  (defun evil-emacs-mode-for-eval (f &rest args)
    (interactive)
    (evil-save-state
     (save-excursion
       (evil-emacs-state)
       (forward-char 1)
       (apply f args))))
  
  (defun evil-lisp-update-cursor-for-eval (f &rest args)
    (interactive)
    (if (and
         (evil-normal-state-p)
         (looking-at (rx (or "(" "[" "{"))))
        (save-excursion
          (paredit-forward)
          (funcall f args))
      (funcall f args)))

  (defun evil-lisp-update-cursor-for-pprint (f &rest args)
    (interactive)
    (save-excursion
      (evil-save-state
       (cond
        ((and
          (evil-normal-state-p)
          (looking-at (rx (or ")" "]" "}"))))
         (evil-emacs-state)
         (forward-char 1)
         (apply f args)
         )
        ((and
          (evil-normal-state-p)
          (looking-at (rx (or "(" "(" "{"))))
         (evil-emacs-state)
         (paredit-forward)
         (apply f args))
        (t (apply f args))))))

  (defun evil-lisp-update-end-cursor-for-eval (f &rest args)
    (interactive)
    (message "args: %s" args)
    (if (and
         (evil-normal-state-p)
         (looking-at (rx (or ")" "]" "}"))))
        (save-excursion
          (evil-save-state
           (evil-emacs-state)
           (forward-char 1)
           (apply f args)))
      (apply f args)))
  (advice-add 'cider-eval-last-sexp :around #'evil-lisp-update-cursor-for-eval)
  (advice-add 'cider-pprint-eval-last-sexp :around #'evil-emacs-mode-for-eval)
  (advice-add 'bso/cider-def-var :around #'evil-lisp-update-cursor-for-pprint)
  (advice-add 'eros-eval-last-sexp :around #'evil-lisp-update-cursor-for-eval))

(use-package! harpoon
  :demand t
  :config
  (map! :map general-override-mode-map
        :leader :prefix "j"
        "j" #'harpoon-quick-menu-hydra
        "a" #'harpoon-add-file
        "1" #'harpoon-go-to-1
        "2" #'harpoon-go-to-2
        "3" #'harpoon-go-to-3
        "4" #'harpoon-go-to-4
        "5" #'harpoon-go-to-5))

(after! cider
  (map! :mode cider-mode
        :n ">" #'paredit-forward-slurp-sexp
        :n "<" #'paredit-forward-barf-sexp

        :localleader
        "e p" #'cider-pprint-eval-last-sexp
        "e v" #'bso/cider-def-var))

(use-package! majutsu
  :demand t
  :config

  (map!
   :map majutsu-log-mode-map)

  (map! :leader
        "g g" #'majutsu))
