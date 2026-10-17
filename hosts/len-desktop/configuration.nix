{ inputs, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/common.nix
    ../../modules/desktop.nix
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-nvidia
  ];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    prime = {
      sync.enable = false;
      offload.enable = false;
      reverseSync.enable = false;
    };
    open = true;
    modesetting.enable = true;
  };

  boot.loader = {
    timeout = 30 * 60;
    efi.canTouchEfiVariables = true;
    limine = {
      enable = true;
      extraEntries = ''
        /Windows
          protocol: efi
          path: uuid(f94dc70e-5fb0-4083-9c9c-e1a933a8bd94):/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
  };

  networking.hostName = "len-desktop";

  system.stateVersion = "25.11";
}
