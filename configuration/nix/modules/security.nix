{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.brandon = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable ssh daemon
  services.openssh.enable = true;

  # skip password checks for sudo
  security.sudo.wheelNeedsPassword = false;

  #########################
  # Setup passkey support #
  #########################

  environment.systemPackages = with pkgs; [
    libsecret # keyring support
    seahorse # keyring manager gui
  ];

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

}
