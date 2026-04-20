;;; ../../code/dotfiles/configuration/doom/config/org.el -*- lexical-binding: t; -*-

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(use-package! org
  :init
  (add-hook! org-mode-hook #'auto-fill-mode))

(after! org
  (add-to-list 'org-capture-templates
               '("E" "Emacs" entry
                 (file (concat org-directory "Emacs.org"))
                 "* TODO %?" :empty-lines 1)))

(defconst org-uuid-regexp
  "\\`[0-9a-f]\\{8\\}-[0-9a-f]\\{4\\}-[0-9a-f]\\{4\\}-[0-9a-f]\\{4\\}-[0-9a-f]\\{12\\}\\'"
  "Regular expression matching a universal unique identifier (UUID).")

(defun +org/jump-to-project-local-todo ()
  (interactive)
  (better-jumper-set-jump)
  (find-file
   (concat (projectile-project-root)
           "todo.org")))

(map! :map general-override-mode-map
      :leader :prefix "o"
      "o" '+org/jump-to-project-local-todo)

(defun bso/insert-uuid ()
  "Insert a uuid.  This requires org-mode."
  (interactive)
  (insert (org-id-uuid)))

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "/Users/brandon/code/canopy-connect-notes"))
  :config
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode))
