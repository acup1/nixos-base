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
    configPath = let
      configuredPath = builtins.getEnv "NIXOS_BASE_CONFIG";
      home = builtins.getEnv "HOME";
    in
      if configuredPath != ""
      then configuredPath
      else if home != ""
      then "${home}/.config/config.nix"
      else throw "Cannot locate config.nix: run the build with --impure or set NIXOS_BASE_CONFIG";
    config =
      if builtins.pathExists configPath
      then import (builtins.toPath configPath) {inherit inputs;}
      else throw "Missing ${configPath}. Run ./rebuild once to generate the template; that first build will stop after creating it.";
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
