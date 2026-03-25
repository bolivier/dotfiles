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
    git
  ];

  # available shells
  programs.fish.enable = true;
  programs.bash.enable = true;
}
