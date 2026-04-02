{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };

    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
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
                imports = homeModules;
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
