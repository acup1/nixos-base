{...}: let
  modulesRoot = /Users/gaporoshin/flakes/nixos-modules;
  privateModulesRoot = /Users/gaporoshin/flakes/private-modules;
in {
  username = "gaporoshin";
  hostName = "macbook"; # Set a unique device name without the .local suffix.
  system = "aarch64-darwin";
  flakeDir = "/Users/gaporoshin/flakes/nixos-base";

  moduleSources = [modulesRoot privateModulesRoot];

  modules = [
    (import (modulesRoot + "/macos-base"))
    (import (modulesRoot + "/macos-keyboard"))
    (import (modulesRoot + "/macos-tiling"))
    (import (modulesRoot + "/browsers"))
    (import (modulesRoot + "/dev"))
    (import (modulesRoot + "/doc-redactors"))
    (import (modulesRoot + "/fonts"))
    (import (modulesRoot + "/printing"))
    (import (modulesRoot + "/terminal-emulators"))
    (import (modulesRoot + "/shell"))
    (import (modulesRoot + "/cli-tools"))
    (import (modulesRoot + "/moonlight"))
    (import (modulesRoot + "/devops"))
    (import (modulesRoot + "/vscode"))
    (import (modulesRoot + "/nvf"))
    (import (privateModulesRoot + "/arc"))
    (import (privateModulesRoot + "/ya"))
  ];
}
