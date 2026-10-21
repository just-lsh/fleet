{ inputs, ... }:
let
  wallpaper = ../../assets/wallpaper/dark/2880x1920.png;
in
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

  home-manager.users.len.programs.plasma = {
    workspace.wallpaper = wallpaper;
    kscreenlocker.appearance.wallpaper = wallpaper;
  };

  environment.etc."plasmalogin.conf.d/50-wallpaper.conf".text = ''
    [Greeter][Wallpaper][org.kde.image][General]
    Image=file://${wallpaper}
  '';

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
