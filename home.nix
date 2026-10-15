{
  pkgs,
  inputs,
  username,
  system,
  ...
}: {
  home.stateVersion = "26.05";

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  home.packages = with pkgs; [home-manager];
  # programs.home-manager.enable = true;
}
