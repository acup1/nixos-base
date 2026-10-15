{
  description = "cups nix(mac)os";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs"; #?ref=nixos-26.05";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager"; # /release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    config = import /nix/config.nix {
      inherit inputs;
    };
    username = config.username;
    system = config.system;
    flakeDir = config.flakeDir;
    moduleBundles = config.modules;
  in {
    darwinConfigurations."${username}-OSX" = inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      modules =
        []
        ++ (map (bundle: bundle.darwin or {}) moduleBundles);
      specialArgs = {
        inherit
          self
          inputs
          system
          username
          flakeDir
          ;
      };
    };

    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {system = system;};
      modules =
        [./home.nix]
        ++ (map (bundle: bundle.home or {}) moduleBundles);
      extraSpecialArgs = {
        inherit
          self
          inputs
          username
          system
          flakeDir
          ;
      };
    };
  };
}
