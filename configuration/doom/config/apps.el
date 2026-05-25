;;; -*- lexical-binding: t; -*-

(use-package! magit
  :init
  (map! "C-c g b" #'magit-blame
        "C-c g n" #'+vc-gutter/next-hunk
        "C-c g p" #'+vc-gutter/previous-hunk
        "C-c g r" #'+vc-gutter/revert-hunk))

(use-package! majutsu
  :demand t
  :config
  (map! :leader
        "g g" #'majutsu))
