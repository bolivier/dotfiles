{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.shell.enableFishIntegration = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ./config.fish;
  };

  programs.zoxide.enable = true;
  programs.eza.enable = true;
}
