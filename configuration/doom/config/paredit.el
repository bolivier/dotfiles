;;; ../../code/dotfiles/configuration/doom/config/paredit.el -*- lexical-binding: t; -*-

(use-package! paredit
  :config
  (map!
   :map paredit-mode-map
   "M-<backspace>" 'paredit-backward-kill-word
   "DEL" 'paredit-backward-delete
   ;; :n "D" #'paredit-kill
   "C-c c c" #'sp-clone-sexp
   ))

(add-hook! paredit-mode
  (smartparens-strict-mode -1)
  (smartparens-mode -1))
