{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # ./hardware-configuration.nix  # Replace with nixos-generate-config output
    ../../system/base.nix
  ];

  # Placeholder — replace with real disk config from nixos-generate-config
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "media-server";

  # Avahi (.local resolution)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  system.stateVersion = "25.11";
}
