{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk.nix
    ../../modules/common.nix
    ../../modules/desktop.nix
  ];

  hardware.facter.reportPath = ./facter.json;

  swapDevices = [ ];

  boot.initrd.availableKernelModules = [ "usb_storage" ];

  services.fstrim.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    prime = {
      sync.enable = false;
      offload.enable = false;
      reverseSync.enable = false;
    };
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
  };

  boot.loader = {
    timeout = 30 * 60;
    efi.canTouchEfiVariables = true;
    limine = {
      enable = true;
      maxGenerations = 4;
      extraEntries = ''
        /Windows
          protocol: efi
          path: uuid(f94dc70e-5fb0-4083-9c9c-e1a933a8bd94):/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
  };

  networking.hostName = "workstation";

  system.stateVersion = "25.11";
}
