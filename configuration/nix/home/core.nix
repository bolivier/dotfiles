{ pkgs, ... }:

{
  home.username = "brandon";
  home.homeDirectory = "/home/brandon";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    bat
    curl
    fd
    fzf
    neovim
    nmap
    ouch
    ripgrep
    socat
    tree
    wget
    wl-clipboard
  ];

  # Shell
  home.shell.enableFishIntegration = true;
  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ./config.fish;
  };
  programs.zoxide.enable = true;
  programs.eza.enable = true;
}
