{ pkgs, ... }:

{
  # Hyprland + display manager
  programs.hyprland.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
    };
  };
  services.blueman.enable = true;

  # Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber = {
      enable = true;
      extraConfig."11-bluetooth-policy" = {
        "monitor.bluez.properties" = {
          "bluez5.codecs" = [
            "aac"
            "sbc"
            "sbc_xq"
          ];
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # Keyring
    libsecret
    seahorse

    # Music
    spotify
  ];
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
}
