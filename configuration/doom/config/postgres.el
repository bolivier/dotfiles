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

;;; LSP (sqls) for the comint-compose composer ------------------------------
;;
;; `sqls' is a SQL language server that connects to the database itself and
;; offers schema-aware completion (tables, columns, ...).  It is installed via
;; nix (see configuration/nix/home/dev.nix).  lsp-mode ships a built-in client
;; (`lsp-sqls'); the connection is configured here in elisp via
;; `lsp-sqls-connections' -- the DB is basically always the same.

(after! lsp-mode
  ;; Edit this connection to match your database.  `sslmode=disable' is the
  ;; usual choice for a local Postgres.
  (setq lsp-sqls-connections
        '(((driver . "postgresql")
           (dataSourceName . "host=127.0.0.1 port=5432 user=postgres dbname=postgres sslmode=disable")))))

(defvar my/comint-compose-sql-file-dir
  (expand-file-name "comint-compose/" (or (bound-and-true-p doom-cache-dir)
                                          temporary-file-directory))
  "Directory for the phony backing files that let LSP attach to composers.")

(defun my/comint-compose-maybe-start-lsp ()
  "Start `sqls' via lsp-mode in a SQL composer buffer.
lsp-mode needs a file-visiting buffer, so give the composer a unique
phony `.sql' file name (never actually saved) before attaching."
  (when (and (derived-mode-p 'sql-mode)
             (fboundp 'lsp-deferred))
    (unless buffer-file-name
      (make-directory my/comint-compose-sql-file-dir t)
      (setq buffer-file-name
            (expand-file-name (format "%s.sql"
                                      (replace-regexp-in-string
                                       "[^A-Za-z0-9]+" "-" (buffer-name)))
                              my/comint-compose-sql-file-dir))
      (setq-local buffer-offer-save nil)
      (set-buffer-modified-p nil))
    (lsp-deferred)))

(add-hook 'comint-compose-setup-hook #'my/comint-compose-maybe-start-lsp)
