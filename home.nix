{
  pkgs,
  inputs,
  username,
  ...
}: {
  home.stateVersion = "25.11";

  imports =
    if builtins.pathExists ./home_packages
    then inputs.nixpkgs.lib.fileset.toList (
      inputs.nixpkgs.lib.fileset.fileFilter (file: file.name == "default.nix") ./home_packages
    )
    else [];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.packages = with pkgs; [home-manager];
  # programs.home-manager.enable = true;
}
