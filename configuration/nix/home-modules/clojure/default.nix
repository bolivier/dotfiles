{
  config,
  lib,
  pkgs,
  ...
}:

{

  home.packages = with pkgs; [
    babashka
    clojure
    clojure-lsp
    jdk
  ];

}
