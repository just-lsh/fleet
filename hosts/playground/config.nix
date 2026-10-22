{ modulesPath, ... }:
let
  # Both are expanded by the VM's run script; `just vm` creates them.
  # Lives outside the repo so the VM's disk survives rebuilds.
  stateDir = "\${XDG_STATE_HOME:-$HOME/.local/state}/fleet/playground";
  # A tmpfs copy of the running host's age key, removed when the VM exits.
  keyDir = "\${XDG_RUNTIME_DIR}/fleet/playground";
in
{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ../../shared/common.nix
    ../../shared/desktop.nix
  ];

  virtualisation = {
    memorySize = 8 * 1024;
    cores = 4;
    diskSize = 16 * 1024;
    diskImage = "${stateDir}/playground.qcow2";
    resolution = {
      x = 1920;
      y = 1080;
    };

    # The VM decrypts with the key of whichever host runs it, read-only where
    # sops-nix expects it. It has no key of its own, so no secrets of its own.
    sharedDirectories.sops = {
      source = keyDir;
      target = "/var/lib/sops-nix";
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "playground";

  system.stateVersion = "26.11";
}
