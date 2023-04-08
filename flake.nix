{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, sops-nix }: {

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
