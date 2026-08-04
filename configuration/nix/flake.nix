{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dankcalendar.url = "github:AvengeMedia/dankcalendar";

    # Hyprland straight from upstream. Deliberately NOT following nixpkgs:
    # upstream pins a known-good nixpkgs for its dep closure, and making it
    # follow ours re-introduces version skew (e.g. the glaze mismatch).
    hyprland.url = "github:hyprwm/Hyprland";

  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      dankcalendar,
      ...
    }:
    let
      mkNixos =
        {
          hostModule,
          homeModules,
          system ? "x86_64-linux",
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            hostModule
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.brandon = {
                imports = homeModules ++ [ dankcalendar.homeModules.default ];
              };
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
    in
    {
      nixosConfigurations.boulevardier = mkNixos {
        hostModule = ./hosts/boulevardier;
        homeModules = [
          ./home/core.nix
          ./home/dev.nix
          ./home/desktop.nix
          ./home/games.nix
        ];
      };

      nixosConfigurations.martini = mkNixos {
        hostModule = ./hosts/martini;
        homeModules = [
          ./home/core.nix
          ./home/dev.nix
          ./home/desktop.nix
          ./home/games.nix
        ];
      };

      nixosConfigurations.media-server = mkNixos {
        hostModule = ./hosts/media-server;
        homeModules = [
          ./home/core.nix
        ];
      };

      # work-mac: will use nix-darwin once configured
      # darwinConfigurations.work-mac = mkDarwin {
      #   hostModule = ./hosts/work-mac;
      #   homeModules = [ ./home/core.nix ./home/dev.nix ];
      # };
    };
}
