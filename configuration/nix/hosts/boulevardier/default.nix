{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../system/base.nix
    ../../system/desktop.nix
  ];

  networking.hostName = "boulevardier";
  programs.steam.enable = true;

  system.stateVersion = "25.11";
}
