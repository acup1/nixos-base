# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}: let
  ports = [8080 25565 10022 22 1433];
in {
  imports = [/etc/nixos/hardware-configuration.nix];

  # Bootloader.
  #boot.loader.systemd-boot.enable = true;
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable CUPS to print documents.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
  services.printing = {
    listenAddresses = ["*:631"];
    allowFrom = ["all"];
    browsing = true;
    defaultShared = true;
    openFirewall = true;
  };
  services.printing.enable = true;
  services.printing.drivers = [pkgs.gutenprint pkgs.hplip];

  programs.system-config-printer.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  #users.defaultUserShell = pkgs.zsh;
  #users.users.acup = {
  #  isNormalUser = true;
  #  description = "acup";
  #  extraGroups = ["networkmanager" "wheel" "lp"];
  #  packages = with pkgs; [
  #    #  thunderbird
  #  ];
  #  home = "/run/media/disk/acup";
  #};

  # Install firefox.
  programs.firefox.enable = true;
  #vvirtualisation
  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  users.extraGroups.vboxusers.members = ["acup"];
  boot.kernelParams = ["kvm.enable_virt_at_load=0"];
  boot.kernelModules = ["cdc_acm"];

  #programs.nvf = {
  #  enable = true;
  #  # your settings need to go into the settings attribute set
  #  # most settings are documented in the appendix
  #  #settings = {
  #  #  vim.viAlias = false;
  #  #  vim.vimAlias = true;
  #  #  vim.lsp = {
  #  #    enable = true;
  #  #  };
  #  #  vim.languages.nix.enable=true;
  #  #};
  #};

  #environment.systemPackages = with unstable-pkgs; [
  #  amnezia-vpn
  #];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.

  networking.firewall.allowedTCPPorts = ports;
  networking.firewall.allowedUDPPorts = ports;

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "plugdev"
      "dialout"
      "lp"
      "lpadmin"
      "libvirtd"
    ];
    shell = pkgs.zsh;
  };
}
