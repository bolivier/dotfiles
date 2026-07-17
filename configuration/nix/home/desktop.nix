{
  inputs,
  config,

  pkgs,
  ...
}:

let
  link = config.lib.file.mkOutOfStoreSymlink;
  configDir = "${config.home.homeDirectory}/.config/dotfiles/configuration";
in

{
  home.packages = with pkgs; [
    bluetui
    brave
    hyprshot
    pavucontrol
    slack
    thunderbird
    hyprlock
    quickshell
    sioyek # pdf reader
    kdePackages.okular # pdf reader (trying out the KDE one)
  ];

  home.file.".config/hypr".source = link "${configDir}/hypr";
  home.file.".config/DankMaterialShell".source = link "${configDir}/DankMaterialShell";

  # Dank Material Shell shipped a GCal integrated calendar
  programs.dank-calendar.enable = true;
}
