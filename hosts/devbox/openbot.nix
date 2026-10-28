# OpenBot as a self-hosted server: the official image, run as upstream's docs/docker.md runs it.
# Sign in once, with an email code, and connect the phone app the same way:
#   sudo podman exec -it openbot openbot login
#   sudo podman exec -it openbot openbot mobile-connect
# Providers sign in from the OpenBot app; their sign-ins stay in the data folder.
#
# Bump `version`, the image digest and the seccomp hash together. OpenBot migrates its database on
# the first start of a new version, and an older one cannot open it, so never roll back past a bump.
# Stop the container and copy the data folder before each bump.
{ pkgs, ... }:
let
  version = "0.52.1";

  # Upstream's Docker profile plus clone and unshare, so the Electron sandbox can make user namespaces.
  seccomp = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/nightly-labs/openbot/v${version}/docker/seccomp.json";
    hash = "sha256-ZlKJ5qHEEEX1UWbQsBmTySn3HfeOOjsmTzJSu44LPZ4=";
  };

  # The image user (UID 1000) maps to a host UID no one owns, never to len.
  idBase = 2000000;
  dataOwner = toString (idBase + 1000);
  dataDir = "/var/lib/openbot";
in
{
  virtualisation.oci-containers = {
    backend = "podman";
    containers.openbot = {
      image = "ghcr.io/nightly-labs/openbot:${version}@sha256:6969bc4e3a4d3c6e23425d011a6cb8a9e9a15b19e7c60e11c89d0d661e6f0d1d";
      # The database, workspaces, provider sign-ins and the keyring with its password, kept together.
      volumes = [ "${dataDir}:/data" ];
      extraOptions = [
        "--uidmap=0:${toString idBase}:65536"
        "--gidmap=0:${toString idBase}:65536"
        "--security-opt=seccomp=${seccomp}"
        "--security-opt=no-new-privileges"
        "--shm-size=1g"
        "--stop-timeout=60"
        # No swap: a container that swaps stalls, and its clients lose the connection.
        "--memory=2g"
        "--memory-swap=2g"
      ];
    };
  };

  systemd.tmpfiles.rules = [ "d ${dataDir} 0700 ${dataOwner} ${dataOwner} -" ];

  # Agents reach the devbox's services at host.containers.internal, and the tailnet through NAT.
  networking.firewall.trustedInterfaces = [ "podman0" ];
}
