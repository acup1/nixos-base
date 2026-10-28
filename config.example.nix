{...}: let
  # Локальные модули читаются напрямую; для flake-команд нужен --impure.
  modulesRoot = /home/acup/flakes/modules;
in {
  username = "acup";
  system = "x86_64-linux";
  flakeDir = "/home/acup/flakes/nixos";

  modules = [
    (import (modulesRoot + "/base"))
    (import (modulesRoot + "/bootloader"))
    (import (modulesRoot + "/caelestia-shell"))
    (import (modulesRoot + "/browsers"))
    (import (modulesRoot + "/qbittorrent"))
    (import (modulesRoot + "/nix-serve"))
    (import (modulesRoot + "/sunshine"))
    (import (modulesRoot + "/sunshine-frp"))
    (import (modulesRoot + "/moonlight"))
    (import (modulesRoot + "/terminal"))
    (import (modulesRoot + "/android"))
    (import (modulesRoot + "/dev"))
    (import (modulesRoot + "/devops"))
    (import (modulesRoot + "/doc-redactors"))
    (import (modulesRoot + "/file-viewers"))
    (import (modulesRoot + "/fonts"))
    (import (modulesRoot + "/games"))
    (import (modulesRoot + "/circuit-artist"))
    (import (modulesRoot + "/graphics"))
    (import (modulesRoot + "/hardware"))
    (import (modulesRoot + "/math"))
    (import (modulesRoot + "/messengers"))
    (import (modulesRoot + "/multimedia"))
    (import (modulesRoot + "/printing"))
    (import (modulesRoot + "/sound"))
    (import (modulesRoot + "/vpn"))
    (import (modulesRoot + "/WM-DE/hypr"))
    (import (modulesRoot + "/WM-DE/niri"))
    (import (modulesRoot + "/WM-DE/drift"))
    (import (modulesRoot + "/WM-DE/gnome"))
  ];
}
