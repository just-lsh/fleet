{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk.nix
    ../../shared/common.nix
    ../../shared/desktop.nix
  ];

  hardware.facter.reportPath = ./facter.json;

  services.fstrim.enable = true;

  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = false;

  boot.loader = {
    efi.canTouchEfiVariables = true;
    limine = {
      enable = true;
      maxGenerations = 4;
    };
  };

  networking.hostName = "laptop";

  system.stateVersion = "26.11";
}
