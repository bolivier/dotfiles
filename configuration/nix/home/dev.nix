{ config, pkgs, ... }:

let
  emacs-with-vterm = (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages (epkgs: [ epkgs.vterm ]);
  user-settings = {
    name = "Brandon Olivier";
    email = "brandon@brandonolivier.com";
  };
in

{
  home.packages = with pkgs; [
    # Editors
    claude-code
    emacs-with-vterm
    lazygit

    # Clojure
    babashka
    clojure
    clojure-lsp
    jdk

    # Formatting / LSP
    fira-code
    nixd
    nixfmt
    nodePackages.prettier
  ];

  home.sessionVariables.EDITOR = "nvim";

  home.file.".config/doom".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/configuration/doom";

  programs.git = {
    enable = true;
    settings.user = user-settings;
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };

  programs.jujutsu.enable = true;
  programs.jujutsu.settings.user = user-settings;
  programs.jujutsu.settings.aliases = {
    tug = [
      "bookmark"
      "move"
      "--from"
      "heads(::@- & bookmarks())"
      "--to"
      "@-"
    ];
  };

  programs.ghostty.enable = true;
}
