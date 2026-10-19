{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk.nix
    ../../modules/common.nix
    ../../modules/desktop.nix
  ];

  hardware.facter.reportPath = ./facter.json;

  services.fstrim.enable = true;

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
