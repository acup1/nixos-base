{
  description = "cups nixos";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules =
        [
          ./programs/default.nix
          {networking.hostName = config.hostName or "nixos";}
        ]
        ++ (nixpkgs.lib.filesystem.listFilesRecursive ./configuration)
        ++ (if builtins.pathExists ./packages then (inputs.nixpkgs.lib.filesystem.listFilesRecursive ./packages) else [])
        ++ (map (bundle: bundle.nixos or {}) moduleBundles);
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
      pkgs = import nixpkgs {inherit system;};
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
