(defun bso/nix-rebuild-finish (buffer status)
  "Close the nixos-rebuild buffer and restore windows if successful."
  (when (equal (buffer-name buffer) "*nixos-rebuild*")
    (if (string-match-p "^finished" status)
        (progn
          (message "NixOS rebuild succeeded.")
          (kill-buffer buffer)
          (when bso/nix-rebuild--window-config
            (set-window-configuration bso/nix-rebuild--window-config)
            (setq bso/nix-rebuild--window-config nil)))
      (message "NixOS rebuild failed — check *nixos-rebuild* for details."))))

(defun bso/nix-rebuild-config (&optional arg)
  "Rebuild the NixOS configuration using the current hostname as the flake target.
With prefix ARG, prompt to edit the full command before running."
  (interactive "P")
  (let* ((flake-path "/home/brandon/.config/dotfiles/configuration/nix")
         (default-cmd (format "sudo nixos-rebuild switch --flake %s#%s"
                              flake-path (system-name)))
         (cmd (if arg
                  (read-shell-command "nixos-rebuild: " default-cmd)
                default-cmd))
         (compilation-buffer-name-function
          (lambda (_mode) "*nixos-rebuild*")))
    (setq bso/nix-rebuild--window-config (current-window-configuration))
    (compile cmd)
    (delete-other-windows (get-buffer-window "*nixos-rebuild*"))))

(use-package! nix-mode
  :demand t
  :config
  (add-to-list 'compilation-finish-functions #'bso/nix-rebuild-finish)
  (map! 
   :localleader "r" #'bso/nix-rebuild-config))
