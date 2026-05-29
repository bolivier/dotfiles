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

  (map!
   :map majutsu-log-mode-map)

  (map! :leader
        "g g" #'majutsu))

(comment
 (use-package! jj-mode
   :init
   (map!
    "C-c g g" #'jj-log)))

(use-package! prodigy
  :defer nil
  :init
  (defun prodigy-set-tag-filter ()
    "Read tag and add filter so that only services with that tag show."
    (interactive)
    (prodigy-with-refresh
     (let ((tag (prodigy-read-tag)))
       (prodigy-clear-filters)
       (prodigy-add-filter :tag tag))))

  (map!
   :leader :prefix "o"
   "p" #'prodigy))
