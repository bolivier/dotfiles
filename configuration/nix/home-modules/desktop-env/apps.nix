{
  inputs,
  config,
  pkgs,
  ...
}:
{

  home.packages = with pkgs; [
    bluetui
    brave
    ghostty
    pavucontrol
    slack
    thunderbird
  ];

}
