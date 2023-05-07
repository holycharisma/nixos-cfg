{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";    

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self, nixpkgs, home-manager, sops-nix, darwin, devenv, ... }: {

    # darwin-rebuild build --flake .#lisa
    # darwin-rebuild switch --flake .#lisa

    darwinConfigurations.lisa = darwin.lib.darwinSystem rec {
      system = "aarch64-darwin";
      modules = [
        ./machines/lisa/darwin-configuration.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.orpheus = import ./users/orpheus/home.nix { 
            lib = nixpkgs.lib;
            pkgs = nixpkgs.legacyPackages.${system};
            system = system;
            devenv = devenv;
          };
        }
      ];
    };

    nixosConfigurations.homer = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./machines/homer/configuration.nix
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.admin = import ./users/admin/home.nix;
          }
      ];
    };
    
    nixosConfigurations.marge = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ 
        ./machines/marge/configuration.nix
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.admin = import ./users/admin/home.nix;
          }
      ];
    };

  };
}
