{
  inputs,
  config,
  pkgs,
  ...
}:

let
  link = config.lib.file.mkOutOfStoreSymlink;
  configDir = "${config.home.homeDirectory}/.config/dotfiles/configuration";
in

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell.enable = true;

  # DMS is an alternative shell to noctalia
  # programs.dms-shell = {
  #   enable = true;

  #   systemd = {
  #     enable = true; # Systemd service for auto-start
  #     restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
  #   };

  #   # Core features
  #   enableSystemMonitoring = true; # System monitoring widgets (dgop)
  #   enableVPN = true; # VPN management widget
  #   enableDynamicTheming = true; # Wallpaper-based theming (matugen)
  #   enableAudioWavelength = true; # Audio visualizer (cava)
  #   enableCalendarEvents = true; # Calendar integration (khal)
  #   enableClipboardPaste = true; # Pasting from the clipboard history (wtype)
  # };

  home.packages = with pkgs; [
    bluetui
    brave
    hyprshot
    pavucontrol
    slack
    thunderbird
    hyprlock
    quickshell
  ];

  home.file.".config/hypr".source = link "${configDir}/hypr";
  home.file.".config/noctalia".source = link "${configDir}/noctalia";
}
