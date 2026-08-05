{ pkgs, ... }:

{
  # User
  users.users.brandon = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  # Auth
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Shells
  programs.fish.enable = true;
  programs.bash.enable = true;

  # Nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Hyprland's official binary cache, so consuming their flake doesn't mean
  # compiling the whole hypr* stack from source on every bump.
  nix.settings.substituters = [ "https://hyprland.cachix.org" ];
  nix.settings.trusted-public-keys = [
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  ];
  nixpkgs.config.allowUnfree = true;

  # Boot
  boot.loader.systemd-boot.enable = true;
  # Cap boot entries kept in the ESP. Without this, systemd-boot keeps a
  # kernel+initrd for *every* generation, which fills the small 487M /boot
  # partition and makes switches fail at the bootloader step. The installer
  # garbage-collects generations beyond this limit before writing the new one.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  # Locale
  #     # NTP time sync — enabled by default on NixOS, but explicit is fine
  services.timesyncd.enable = true;

  # Auto-update timezone from geolocation
  services.automatic-timezoned.enable = true;

  # automatic-timezoned needs geoclue; the module pulls it in,
  # but you may want to ensure the agent is allowed:
  location.provider = "geoclue2";

  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;
  services.xserver.xkb.layout = "us";

  services.openvpn.servers = {
    nordvpn = {
      config = "config /home/brandon/.config/nordvpn/server.ovpn";
      autoStart = false; # set to true if you want it on boot
    };
  };

  # Safety packages (duplicated from home-manager for TTY/rescue access)
  environment.systemPackages = with pkgs; [
    babashka

    bluetui
    curl
    fd
    file
    git
    lsof
    neovim
    ouch
    ripgrep
    tree
    wget
    openvpn
  ];

  # Network
  networking.networkmanager.enable = true;
}
