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
    thunderbird
    socat
    brave
    bluetui
    pavucontrol
    ghostty
    lazygit
    nixd
    nixfmt
    fira-code
    slack
    nodePackages.prettier
  ];

  imports = [
    ./home-modules/shell/fish.nix
    ./home-modules/clojure/default.nix
    ./home-modules/dev-env/default.nix
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
  };

  home.file.".config/hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/configuration/hypr";

  home.file.".config/noctalia".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/configuration/noctalia";
}
