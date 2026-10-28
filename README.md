# nixos
 nixos flake
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
