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
    inherit (config) username system flakeDir;
    installerRelease = nixpkgs.lib.importJSON ./nixos-installer/release.json;
    installerSystems = builtins.filter (system: builtins.hasAttr system installerRelease.hashes) nixpkgs.lib.systems.flakeExposed;
    mkNixosSystem = {config, extraModules ? []}: nixpkgs.lib.nixosSystem {
      inherit (config) system;
      modules =
        [
          ./programs/default.nix
          ./nixos-installer/system.nix
          {networking.hostName = config.hostName or "nixos";}
        ]
        ++ (
          if config ? nixosHostConfiguration
          then [config.nixosHostConfiguration]
          else nixpkgs.lib.filesystem.listFilesRecursive ./configuration
        )
        ++ (if builtins.pathExists ./packages then (inputs.nixpkgs.lib.filesystem.listFilesRecursive ./packages) else [])
        ++ (map (bundle: bundle.nixos or {}) config.modules)
        ++ extraModules;
      specialArgs = {
        inherit (config) system username flakeDir;
        inherit
          self
          inputs
          ;
      };
    };
  in {
    lib.mkNixosSystem = mkNixosSystem;

    packages = nixpkgs.lib.genAttrs installerSystems (system: {
      nixos-installer = nixpkgs.legacyPackages.${system}.callPackage ./nixos-installer/package.nix {};
    });

    nixosConfigurations.nixos = mkNixosSystem {inherit config;};

    homeConfigurations = {
      ${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {inherit system;};
        modules =
          [./home.nix]
          ++ (map (bundle: bundle.home or {}) config.modules);
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
  };
}
