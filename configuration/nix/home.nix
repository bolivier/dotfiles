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
  ];

  imports = [
    ./home-modules/shell/fish.nix
    ./home-modules/clojure/default.nix
    ./home-modules/dev-env/default.nix
    ./home-modules/desktop-env/default.nix
  ];
}
