{ pkgs, ... }:
{
  # Rootless podman for len. As a normal user, len already gets subordinate UID
  # and GID ranges (from 100000) for the user namespace.
  virtualisation.podman = {
    enable = true;
    # `docker` runs podman, for tools and scripts that call docker.
    dockerCompat = true;
    # Tools that speak the Docker API find rootful podman at /run/docker.sock.
    dockerSocket.enable = true;
    # Containers on the same network reach each other by name.
    defaultNetwork.settings.dns_enabled = true;
  };

  # Lets len use the Docker socket, which makes len root-equivalent.
  users.users.len.extraGroups = [ "podman" ];

  environment.systemPackages = with pkgs; [
    podman-compose
    distrobox
  ];
}
