{ config, pkgs, ... }: {
  home.username = "brandon";
  home.homeDirectory = "/home/brandon";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    babashka
    clojure
    clojure-lsp
    jdk
    socat
    brave
    bluetui
    pavucontrol
    neovim
    git
    emacs
    hyprland 
    ghostty
    eza
  ];

  home.file.".config/fish".source = 
  	config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/configuration/fish";

  home.file.".config/doom".source = 
  	config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/configuration/doom";

  home.file.".config/hypr".source = 
  	config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/configuration/hypr";
  programs.ghostty.enable = true;

  home.shell.enableFishIntegration = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "Brandon Olivier";
      email = "brandon@brandonolivier.com";
    };
  };

  programs.jujutsu.enable = true;
  programs.zoxide.enable = true;
}
