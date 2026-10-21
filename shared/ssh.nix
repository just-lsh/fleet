{ config, lib, ... }:
let
  # Every host's public keys sit in plain text next to its encrypted secrets.
  # A host joins once `just secrets ssh <host>` has written them.
  hostsDir = ../hosts;
  hosts = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir hostsDir));
  withFile = file: lib.filter (host: builtins.pathExists (hostsDir + "/${host}/${file}")) hosts;

  hostDir = hostsDir + "/${config.networking.hostName}";
  hasKeys = builtins.pathExists (hostDir + "/secrets.yaml");
in
{
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      MaxAuthTries = 3;
      LoginGraceTime = 30;
      LogLevel = "VERBOSE";
      ClientAliveInterval = 60;
      ClientAliveCountMax = 10;
    };
  };

  # Each host's len may log in to every host.
  users.users.len.openssh.authorizedKeys.keys = map (
    host: lib.fileContents (hostsDir + "/${host}/id_ed25519.pub")
  ) (withFile "id_ed25519.pub");

  # Hosts recognise each other by name without a trust-on-first-use prompt.
  programs.ssh.knownHosts = lib.genAttrs (withFile "ssh_host_ed25519_key.pub") (host: {
    publicKeyFile = hostsDir + "/${host}/ssh_host_ed25519_key.pub";
  });

  sops.secrets = lib.mkIf hasKeys {
    ssh-host-key = {
      sopsFile = hostDir + "/secrets.yaml";
      key = "ssh/host";
      path = "/etc/ssh/ssh_host_ed25519_key";
    };
    ssh-user-key = {
      sopsFile = hostDir + "/secrets.yaml";
      key = "ssh/user";
      owner = "len";
      path = "/home/len/.ssh/id_ed25519";
    };
  };

  # sops-nix creates missing parent directories as root.
  systemd.tmpfiles.rules = [ "d /home/len/.ssh 0700 len users -" ];

  home-manager.users.len.home.file.".ssh/id_ed25519.pub" = lib.mkIf hasKeys {
    source = hostDir + "/id_ed25519.pub";
  };
}
