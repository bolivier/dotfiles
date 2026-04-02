{ inputs, config, pkgs, ... }:

let
  link = config.lib.file.mkOutOfStoreSymlink;
  configDir = "${config.home.homeDirectory}/.config/dotfiles/configuration";
in

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell.enable = true;

  home.packages = with pkgs; [
    bluetui
    brave
    hyprshot
    pavucontrol
    slack
    thunderbird
  ];

  home.file.".config/hypr".source = link "${configDir}/hypr";
  home.file.".config/noctalia".source = link "${configDir}/noctalia";
}
