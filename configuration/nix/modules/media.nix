{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.avahi
    pkgs.nmap
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true; # enables .local resolution
  };
}
