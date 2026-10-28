{...}: let
  modulesRoot = /Users/gaporoshin/flakes/nixos-modules;
  privateModulesRoot = /Users/gaporoshin/flakes/private-nix-modules;
in {
  username = "gaporoshin";
  system = "aarch64-darwin";
  flakeDir = "/Users/gaporoshin/flakes/nixos-base";

  modules = [
    (import (modulesRoot + "/macos-base"))
    (import (modulesRoot + "/macos-keyboard"))
    (import (modulesRoot + "/macos-tiling"))
    (import (modulesRoot + "/macos-packages"))
    (import (modulesRoot + "/moonlight"))
    (import (modulesRoot + "/devops"))
    (import (modulesRoot + "/macos-home"))
    (import (modulesRoot + "/vscode"))
    (import (modulesRoot + "/nvf"))
    (import (privateModulesRoot + "/arc"))
    (import (privateModulesRoot + "/ya"))
  ];
}
