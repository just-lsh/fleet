{ inputs, ... }:
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ./plasma.nix
    ./apps.nix
    ./shell.nix
    ./git.nix
    ./helix.nix
    ./ghostty.nix
    ./zed.nix
    ./agents.nix
  ];

  home.stateVersion = "26.11";
}
