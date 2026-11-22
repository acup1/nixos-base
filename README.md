# nixos
 nixos flake
## Quick start

If Nix is installed, run the installer from any directory.

```sh
nix --extra-experimental-features 'nix-command flakes' run github:acup1/nixos-base/macos#nixos-installer
```

If Nix is missing, the release script installs it and starts the matching installer binary.

```sh
curl -fsSL --proto '=https' --tlsv1.2 https://github.com/acup1/nixos-installer/releases/latest/download/bootstrap.sh | sh
```

## Preview
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/5d1e1a36-ad2b-4299-b510-32ca716e3fc7" />

## to install on macos
```sh
./rebuild system switch
./rebuild home switch
```

Both commands read `~/.config/config.nix`. If it is missing, `rebuild` copies
`config.example.nix` there and exits with an error so the generated file can be
reviewed before the first build. Direct flake commands must use `--impure`.

Set a unique `hostName` in `~/.config/config.nix` on each Mac, for example
`hostName = "macbook";`. After `./rebuild system switch`, Bonjour uses that
name as `macbook.local`. With no `hostName` entry, macOS keeps its current name.

The host pins nixpkgs, nix-darwin and Home Manager. The browsers component pins
Zen in `browsers/inputs/flake.lock`. Host selectors that need the Zen input can
read `(import (modulesRoot + "/browsers")).inputs.zen-browser`.

The system profile includes `nixos-installer` on supported Macs. The flake
downloads the pinned GitHub release binary for the host architecture and
verifies its SHA-256. If the selector already includes the `nixos-installer`
component, that component controls the package.
The standalone package is available as `nix run .#nixos-installer` and can be
used without a host selector. The pinned nixpkgs supports Apple Silicon.
