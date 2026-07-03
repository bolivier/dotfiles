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

    # Building packages
    gcc

    # Clojure
    babashka
    clojure
    clojure-lsp
    jdk
    zprint
    clj-kondo
    leiningen

    # Javascript
    typescript-language-server
    nodejs
    bun
    prettier

    # Haskell
    ghc
    haskell-language-server

    # Smalltalk
    pharo

    # Rust
    rustup

    # SQL
    sqls
    sqlite
    postgresql # Daemon not automatically started

    # Nix specific
    fira-code
    nixd
    nixfmt
    direnv # Auto start dev shells

    # Lua
    # motivated by hyprland lua config
    lua
    luaformatter
    luarocks-nix
    lua-language-server
  ];

  home.sessionVariables.EDITOR = "emacsclient -c -a ''";

  home.file.".config/doom".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/dotfiles/configuration/doom";

  programs.git = {
    enable = true;
    settings = {
      user = user-settings;
      init.defaultBranch = "main";
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };

  programs.jujutsu.enable = true;
  programs.jujutsu.settings.user = user-settings;
  programs.jujutsu.settings.ui.conflict-marker-style = "snapshot";
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
