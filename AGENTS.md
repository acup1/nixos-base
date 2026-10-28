# Repository Guidelines

## Project Structure & Module Organization

This repository is a Nix flake for one NixOS host and one Home Manager profile. `flake.nix` defines `nixosConfigurations.nixos` and `homeConfigurations.acup`; keep modules reachable from those outputs.

- `configuration/`: host-specific NixOS settings, accounts, extra firewall ports and hardware services.
- `packages/`: grouped system package lists and package categories.
- `home.nix`: Home Manager entry point for user `acup`.
- `home_packages/`: per-application Home Manager modules; prefer `default.nix` inside each app directory.
- `programs/`: custom package/program definitions included by the NixOS configuration.
- `../modules/`: component bundles alongside this repository, imported directly from the `modulesRoot` path defined inside `~/.config/config.nix`. Every component exports `nixos` and/or `home` from `default.nix`. Use `configuration/`, `packages/`, and `home_packages/` within each component, matching the host's organization; `nixos.nix` and `home.nix` import those parts. Sunshine, sunshine-frp, and Moonlight are independent components.
- `~/.config/config.nix`: machine-local settings imported directly by `flake.nix`, outside the flake input graph. It defines `username`, `system`, `flakeDir`, and the `modules` list. `config.example.nix` is the bootstrap template; `rebuild` copies it into place and stops when the configuration is missing. Configuration and component changes do not require lockfile updates. Direct local imports require `--impure`. Do not add a second `modules/` directory inside this repository.
- `../modules/base/`: basic system packages in `packages/base.nix`; Nix, cache clients, NH, SSH, NetworkManager, locale, documentation and shell setup in `configuration/`. Keep graphical additions and optional applications out of base: the NetworkManager applet belongs to `WM-DE/common`, while `qbittorrent` and `nix-serve` are separate selectable bundles.
- `../modules/WM-DE/`: independent `hypr`, `niri`, `drift`, and `gnome` bundles. Each imports `common` by path for shared OS/Home settings, including GDM, portals, input, graphics, sensors, audio, power and shell/theming modules. Keep compositor-specific configuration, packages and assets in its component. DriftWM and DMS upstream module imports belong to these bundles, not the root entry points.
- `../modules/bootloader/`: GRUB/UEFI settings in `configuration/`; theme assets and packaging in `grub_themes/`. The original bootloader file also keeps the `aarch64-linux` binfmt setting.

There is no dedicated test directory. Use static inspection and syntax checks for routine changes; configuration builds require an explicit user request.

## Build, Test & Development Commands

The build and flake-check commands below are for use only when explicitly requested by the user. Do not run them automatically as part of an edit, review, or PR.

- `nix flake check --impure`: evaluate flake outputs and catch module or lockfile issues.
- `./rebuild system build`: build the system closure without switching to it.
- `./rebuild home build`: build the Home Manager generation without activating it.
- `nix flake update`: update pinned inputs in `flake.lock`; review resulting package and module changes carefully.

Run commands from the repository root. Direct imports of external local modules require `--impure`; `../modules/base/configuration/nh.nix` adds it to NixOS build/apply commands and Home Manager switch/build commands. Avoid committing the `result` symlink produced by Nix builds.

## Coding Style & Naming Conventions

Use idiomatic Nix with 2-space indentation for nested attribute sets and lists. Prefer small, focused modules over large mixed-purpose files. Name files by topic, for example `configuration/sshd.nix`, `packages/fonts.nix`, or `home_packages/ghostty/default.nix`.

Keep host constants in `config.example.nix`; `flake.nix` reads them from `~/.config/config.nix`. Add packages to the most specific existing group.

## Testing Guidelines

Do not build NixOS or Home Manager configurations unless the user explicitly requests a build. This includes `nixos-rebuild build`, `home-manager build`, and `nix build` of configuration outputs. Do not run `nix flake check` automatically either, since it can trigger builds.

For routine changes, inspect the diff, run `git diff --check`, and use syntax-only checks such as `nix-instantiate --parse` when useful. Do not start configuration builds merely to validate a change or prepare a PR. Keep custom modules reachable from their parent configuration through static inspection. If the user explicitly requests validation by building, use the relevant command above and report its result.

## Commit & Pull Request Guidelines

Recent history uses short, informal commit subjects such as `upd`, `large upd`, and `nvf`. Keep commits concise, but make them more descriptive when possible, for example `hypr: update window manager packages` or `home: add ghostty settings`.

Pull requests should describe the affected area, list validation commands run, and call out lockfile updates, new services, firewall ports, or hardware assumptions. Include screenshots only for visible UI/theme changes.

## Security & Configuration Tips

Do not commit secrets, machine-local tokens, or private keys. Be cautious with SSH, firewall ports, binary caches, Docker/VirtualBox, and `allowUnfree`; mention those explicitly in reviews.
