;;; ../../code/dotfiles/configuration/doom/config/paredit.el -*- lexical-binding: t; -*-

(use-package! paredit
  :hook (clojure-mode cider-repl-mode emacs-lisp-mode lisp-interaction-mode)
  :config
  (map!
   :map paredit-mode-map
   "M-<backspace>" 'paredit-backward-kill-word
   "DEL" 'paredit-backward-delete))

(add-hook! paredit-mode
  (defun bso/turn-off-smartparens ()
    (smartparens-strict-mode -1)
    (smartparens-mode -1)))
