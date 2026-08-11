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
  ];

  networking.hostName = "ale";

  # Temporary XFCE desktop for setup. Comment out or delete when done.
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

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
    virtualHosts."ale.local" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:32400";
        proxyWebsockets = true;
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 ];

  # Media storage: sda2 mounted at /mnt/disk1, plus /mnt/disk2 as a plain
  # directory on the root disk (sdb also holds /). mergerfs unions them at
  # /mnt/media. Each file lives whole on one branch; no striping.
  fileSystems."/mnt/disk1" = {
    device = "/dev/disk/by-uuid/b27c93b7-2d07-402d-af59-4fa19aa2e3d9";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

  fileSystems."/mnt/media" = {
    device = "/mnt/disk1:/mnt/disk2";
    fsType = "fuse.mergerfs";
    options = [
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=mfs"
      # keep 100G free per branch so media can never fill the root disk
      "minfreespace=100G"
      "fsname=mergerfs-media"
      "allow_other"
      "nofail"
      "x-systemd.requires=/mnt/disk1"
    ];
  };

  environment.systemPackages = [ pkgs.mergerfs ];
  services.fstrim.enable = true;

  # Media dirs group-writable so brandon can add files
  systemd.tmpfiles.rules = [
    "d /mnt/disk1 2775 plex plex -"
    "d /mnt/disk2 2775 plex plex -"
    "d /mnt/media 2775 plex plex -"
  ];
  users.users.brandon.extraGroups = [ "plex" ];

  # VA-API for hardware transcoding (needs Plex Pass)
  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  system.stateVersion = "25.11";
}
