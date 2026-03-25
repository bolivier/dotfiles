{
  config,
  lib,
  pkgs,
  ...
}:

{

  environment.systemPackages = with pkgs; [
    wget
    brave
    neovim
    wl-clipboard
    git
  ];

  # available shells
  programs.fish.enable = true;
  programs.bash.enable = true;
}
