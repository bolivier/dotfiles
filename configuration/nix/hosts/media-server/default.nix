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

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  # Serve the web UI at port 80; Plex apps still use 32400
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."media-server.local" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:32400";
        proxyWebsockets = true;
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 ];

  # Media library at /srv/media, group-writable so brandon can add files
  systemd.tmpfiles.rules = [
    "d /srv/media 2775 plex plex -"
  ];
  users.users.brandon.extraGroups = [ "plex" ];

  # VA-API for hardware transcoding (needs Plex Pass)
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  system.stateVersion = "25.11";
}
