{ inputs, ... }:
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ./plasma.nix
    ./apps.nix
    ./ghostty.nix
    ./zed.nix
    ./cursor.nix
  ];
}
