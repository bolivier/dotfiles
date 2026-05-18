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

(defun bro/projectile-invalidate-cache-quietly (&rest _)
  (when (and (bound-and-true-p projectile-mode)
             (projectile-project-p))
    (let ((inhibit-message t))
      (projectile-invalidate-cache nil))))

(defvar bro/projectile-jj-timer nil
  "Periodic projectile cache invalidation; catches jj changes made outside Emacs.")

(when (timerp bro/projectile-jj-timer)
  (cancel-timer bro/projectile-jj-timer))

(setq bro/projectile-jj-timer
      (run-with-timer 180 180 #'bro/projectile-invalidate-cache-quietly))
