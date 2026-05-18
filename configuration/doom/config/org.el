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

(add-hook! org-mode 'auto-fill-mode)

(use-package org-roam
  :ensure t
  ;; :custom
  ;; (org-roam-directory (file-truename "/Users/brandon/work/canopy-connect-notes"))
  :config
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  (map! :map org-mode-map
        ;; Figure out how to move this to `g d`.  +lookup/definition
        :n "g ." #'org-open-at-point
        :i "g" #'self-insert-command)
  


  (setq org-todo-keywords
        '((sequence
           "TODO(t)"  ; A task that needs doing & is ready to do
           "PROJ(p)"  ; A project, which usually contains other tasks
           "LOOP(l)"  ; A recurring task
           "WAIT(w)"  ; Something external is holding up this task
           "HOLD(h)"  ; This task is paused/on hold because of me
           "IDEA(i)"  ; An unconfirmed and unapproved task or notion
           "REVISIT(r)"  ; An unconfirmed and unapproved task or notion
           "|"
           "DONE(d)"  ; Task successfully completed
           "KILL(k)") ; Task was cancelled, aborted, or is no longer applicable
          (sequence
           "[ ](T)"   ; A task that needs doing
           "[-](S)"   ; Task is in progress
           "[?](W)"   ; Task is being held up or paused
           "|"
           "[X](D)")  ; Task was completed
          (sequence
           "|"
           "OKAY(o)"
           "YES(y)"
           "NO(n)"))
        org-todo-keyword-faces
        '(("[-]"  . +org-todo-active)
          ("STRT" . +org-todo-active)
          ("[?]"  . +org-todo-onhold)
          ("WAIT" . +org-todo-onhold)
          ("HOLD" . +org-todo-onhold)
          ("PROJ" . +org-todo-project)
          ("NO"   . +org-todo-cancel)
          ("KILL" . +org-todo-cancel)))
  )
