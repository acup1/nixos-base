{
  lib,
  options,
  pkgs,
  ...
}: let
  release = lib.importJSON ./release.json;
  system = pkgs.stdenv.hostPlatform.system;
  legacyComponent = lib.hasAttrByPath ["components" "nixos-installer" "enabledPackages" "nixos-installer"] options;
in {
  # Existing selectors keep the component's package and settings.
  environment.systemPackages = lib.mkIf (builtins.hasAttr system release.hashes && !legacyComponent) [
    (pkgs.callPackage ./package.nix {})
  ];
}
