;;; $DOOMDIR/config/lua.el -*- lexical-binding: t; -*-

;; lsp-mode's lua client checks for files under Doom's installer dir
;; (~/.emacs.d/.cache/lsp/lua-language-server/) which don't exist on
;; NixOS. The Nix wrapper for lua-language-server already passes
;; `-E .../main.lua` internally and forwards "$@", so we point lsp-mode
;; at the wrapper and short-circuit the install check.
(after! lsp-lua
  (when-let* ((bin (executable-find "lua-language-server")))
    (setq lsp-clients-lua-language-server-bin bin
          lsp-clients-lua-language-server-main-location bin
          lsp-clients-lua-language-server-command (list bin))))
