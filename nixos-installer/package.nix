{
  fetchurl,
  lib,
  runCommand,
  stdenv,
}: let
  system = stdenv.hostPlatform.system;
  release = lib.importJSON ./release.json;
  binary = fetchurl {
    url = "https://github.com/acup1/nixos-installer/releases/download/v${release.version}/nixos-installer-${system}";
    hash = release.hashes.${system};
  };
in
  runCommand "nixos-installer-${release.version}" {
    meta.mainProgram = "nixos-installer";
    meta.platforms = builtins.attrNames release.hashes;
  } ''
    install -Dm755 ${binary} "$out/bin/nixos-installer"
  ''
