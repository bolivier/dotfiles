;;; ../../code/dotfiles/configuration/doom/config/postgres.el -*- lexical-binding: t; -*-

;;;###autoload
(defun switch-to-or-create-postgres-buffer ()
  "Switch to (or create) a postgres buffer"
  (interactive)
  (if-let ((buffer (get-buffer "*SQL: Postgres*")))
      (switch-to-buffer buffer)
    (sql-postgres)))

(map! :leader :prefix "o"
      "d" #'switch-to-or-create-postgres-buffer)
