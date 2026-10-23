{ inputs, ... }:
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ./plasma.nix
    ./apps.nix
    ./shell.nix
    ./eza.nix
    ./git.nix
    ./helix.nix
    ./ghostty.nix
    ./zed.nix
    ./cursor.nix
    ./agents.nix
  ];

  home.stateVersion = "26.11";
}
