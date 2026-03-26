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
  (defun evil-lisp-update-cursor-for-eval (f &rest args)
    (interactive)
    (if (and
         (evil-normal-state-p)
         (looking-at (rx (or "(" "[" "{"))))
        (save-excursion
          (paredit-forward)
          (funcall f args))
      (funcall f args)))

  (advice-add 'cider-eval-last-sexp :around #'evil-lisp-update-cursor-for-eval)
  (advice-add 'cider-pprint-eval-last-sexp :around #'evil-lisp-update-cursor-for-eval)
  (advice-add 'eros-eval-last-sexp :around #'evil-lisp-update-cursor-for-eval)
  )

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

(use-package! majutsu
  :demand t
  :config
  (map! :leader
        "g g" #'majutsu))
