{
  inputs,
  config,
  pkgs,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
  homeDir = config.home.homeDirectory;
  configDir = "${homeDir}/.config/dotfiles/configuration";
in
{
  imports = [
    inputs.noctalia.homeModules.default
    ./apps.nix
  ];

  home.packages = with pkgs; [
    hyprshot
  ];

  programs.noctalia-shell = {
    enable = true;
  };

  home.file.".config/hypr".source = link "${configDir}/hypr";

  home.file.".config/noctalia".source = link "${configDir}/noctalia";
}
