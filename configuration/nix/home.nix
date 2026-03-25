{
  inputs,
  config,
  pkgs,
  ...
}:
{
  home.username = "brandon";
  home.homeDirectory = "/home/brandon";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    socat
    brave
    bluetui
    pavucontrol
    neovim
    git
    emacs
    ghostty
    fzf
    gcc
    curl
    ripgrep
    fd
    lazygit
    ouch
    nixd
    nixfmt
  ];

  imports = [
    ./home-modules/shell/fish.nix
    ./home-modules/clojure/default.nix
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
  };

  home.file.".config/doom".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/configuration/doom";

  home.file.".config/hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/configuration/hypr";

  home.file.".config/noctalia".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/configuration/noctalia";

  programs.ghostty.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "Brandon Olivier";
      email = "brandon@brandonolivier.com";
    };
  };

  programs.jujutsu.enable = true;
}
