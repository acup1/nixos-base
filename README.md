# nixos
 nixos flake
## Preview
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/5d1e1a36-ad2b-4299-b510-32ca716e3fc7" />

## to install on macos
```sh
sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin/master#darwin-rebuild -- switch --flake . --impure
sudo nix-shell -p home-manager switch --flake .#username --impure
```
