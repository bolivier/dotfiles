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

  networking.hostName = "martini";
  programs.steam.enable = true;
  programs.zoom-us.enable = true;
  services.upower.enable = true;

  # Avahi (.local resolution)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Kanata (keyboard remapping)
  services.kanata = {
    enable = true;
    keyboards.default = {
      devices = [ ];
      extraDefCfg = "process-unmapped-keys yes";
      config = ''
        (defsrc
          caps ret prnt
        )

        (defvar
          tap-time 200
          hold-time 150
        )

        (deflayer base
          lctl @ret lmet
        )

        (defalias
          ret (tap-hold $tap-time $hold-time ret lctl)
        )
      '';
    };
  };

  system.stateVersion = "25.11";
}
