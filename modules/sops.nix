{ inputs, config, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../secrets/common.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";

    # Decrypted before users are created, so it can back the login password.
    secrets.len-password.neededForUsers = true;
  };

  # Passwords come only from the config, so `passwd` changes don't survive a switch.
  users.mutableUsers = false;

  users.users.len.hashedPasswordFile = config.sops.secrets.len-password.path;
}
