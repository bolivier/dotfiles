;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(load! "config/ui")
(load! "config/emacs")
(load! "site-lisp/comint-compose")
(load! "site-lisp/tram-mode")
(load! "config/postgres")
(load! "config/org")
(load! "config/editing")
(load! "config/clojure")
(load! "config/paredit")
(load! "config/web")
(load! "config/apps")
;; (load! "config/evil")
(load! "config/nix")
(load! "config/lua")
(load! "config/winnow")
(load! "config/markdown")
(load! "site-lisp/vterm-editor")
(load! "config/unsetting")

(map! :map comint-mode-map
      "C-c C-e" #'comint-compose-open)

(after! vterm
  ;; vterm sends almost everything straight to the terminal, so bind the
  ;; opener on vterm's own map (and keep it out of copy mode confusion).
  (map! :map vterm-mode-map
        "C-c C-e" #'comint-compose-open))
