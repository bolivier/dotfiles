{
  config,
  lib,
  pkgs,
  ...
}:

{

  environment.systemPackages = with pkgs; [
    brave
    curl
    fd
    git
    neovim
    ouch
    ripgrep
    wget
    wl-clipboard
  ];

  # available shells
  programs.fish.enable = true;
  programs.bash.enable = true;
}
