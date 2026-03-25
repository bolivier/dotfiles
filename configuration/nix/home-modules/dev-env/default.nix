{
  config,
  lib,
  pkgs,
  ...
}:

let
  emacs-with-vterm = (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages (epkgs: [ epkgs.vterm ]);
in

{

  home.packages = with pkgs; [
    bat
    fzf
    curl
    ripgrep
    fd
    ouch
    emacs-with-vterm
  ];

  home.file.".config/doom".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/configuration/doom";

  programs.git = {
    enable = true;
    settings.user = {
      name = "Brandon Olivier";
      email = "brandon@brandonolivier.com";
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };

  programs.jujutsu.enable = true;
  programs.ghostty = {
    enable = true;
  };

}
