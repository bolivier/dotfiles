{
  config,
  lib,
  pkgs,
  ...
}:
{

  home.packages = with pkgs; [
    qbittorrent
  ];
  services.avahi = {
    enable = true;
    nssmdns4 = true; # enables .local resolution
  };
}
