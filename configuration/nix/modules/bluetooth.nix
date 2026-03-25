{
  config,
  lib,
  pkgs,
  ...
}:

{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
    };
  };

  services.blueman.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;

    wireplumber = {
      enable = true;
      extraConfig."11-bluetooth-policy" = {
        "monitor.bluez.properties" = {
          "bluez5.codecs" = [ "aac" "sbc" "sbc_xq" ];
        };
      };
    };
  };
}
