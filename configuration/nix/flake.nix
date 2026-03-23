{
  inputs = {
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.boulevardier = nixpkgs.lib.nixosSystem {
      modules = [ 
        ./configuration.nix 
home-manager.nixosModules.home-manager 
{
home-manager.useGlobalPkgs = true;
home-manager.useUserPackages = true;
home-manager.users.brandon = import ./home.nix;
}
      ];
    };
  };
}

