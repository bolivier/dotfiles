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
  nixpkgs.config.allowUnfree = true;

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  # Locale
  time.timeZone = "America/Chicago";
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
    git
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
