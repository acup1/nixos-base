{
  description = "cups nixos";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # nix-serve-ng = {
    #   url = "github:aristanetworks/nix-serve-ng";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    #nvf.url = "github:acup1/nvf";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      # type = "github";
      url = "github:hyprwm/Hyprland";
      # submodules = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    driftwm.url = "github:malbiruk/driftwm";

    # Keep the upstream Rust/GTK stack pinned independently.
    waylandkb.url = "github:acup1/waylandkb";

    # hyprgrass = {
    #   url = "github:horriblename/hyprgrass";
    #   inputs.hyprland.follows = "hyprland";
    # };
    # Hyprspace = {
    #   url = "github:KZDKM/Hyprspace";
    #   inputs.hyprland.follows = "hyprland";
    # };

    iio-hyprland.url = "github:JeanSchoeller/iio-hyprland";

    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri.url = "github:niri-wm/niri";

    nvf = {
      url = "github:notashelf/nvf";
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
