{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.noctalia.nixosModules.default
    inputs.umbriel.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
  ];

  # The noctalia cache also serves the greeter, the umbriel one its portal.
  nix.settings = {
    substituters = [
      "https://noctalia.cachix.org"
      "https://umbriel.cachix.org"
    ];
    trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
    ];
  };

  # Configured in home/.config/noctalia/config.toml.
  programs.noctalia = {
    enable = true;
    # Started by graphical-session.target, which Umbriel brings up.
    systemd.enable = true;
    # NetworkManager, Bluetooth, UPower and power-profiles-daemon.
    recommendedServices.enable = true;
  };

  # Registers the session for the greeter and sets up the portal. Configured
  # in home/.config/umbriel/config.toml.
  programs.umbriel.enable = true;

  services.displayManager.noctalia-greeter = {
    enable = true;

    # The shell's auto-sync copies its wallpaper, palette and monitor layout
    # here. This allows exactly that helper, so it doesn't prompt every time.
    passwordless-sync-users = [ "len" ];

    # Appearance is left to sync, since this file wins over synced values.
    settings = {
      session.default = "Umbriel";
      user.default = "len";
      cursor = {
        theme = "Adwaita";
        size = 24;
        path = "${pkgs.adwaita-icon-theme}/share/icons";
      };
    };
  };

  # Fails the build rather than the session when a config is broken.
  system.checks = [
    (pkgs.runCommand "noctalia-config-check" { } ''
      ${lib.getExe config.programs.noctalia.package} config validate ${../home/.config/noctalia/config.toml}
      touch $out
    '')
    (pkgs.runCommand "umbriel-config-check" { } ''
      ${lib.getExe config.programs.umbriel.package} config validate -c ${../home/.config/umbriel/config.toml}
      touch $out
    '')
  ];

  # launch_apps_as_systemd_services starts apps as app-*.service units, which
  # otherwise outlive the session and keep holding its dead display. A raw unit,
  # since services.* would also pin every app's PATH to a minimal one.
  systemd.user.units."app-.service" = {
    overrideStrategy = "asDropin";
    text = ''
      [Unit]
      PartOf=graphical-session.target
    '';
  };

  # Clipboard history and calendar credentials live in the Secret Service,
  # which KWallet provided under Plasma. greetd's PAM stack unlocks it at login.
  services.gnome.gnome-keyring.enable = true;

  # Neither Umbriel's portal nor the GTK one serves Secret, and gnome-keyring's
  # only claims GNOME. Without this, Electron apps can't keep their encryption
  # key and lose logins on every start.
  xdg.portal.config.umbriel."org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];

  # The cursor theme set in Umbriel's config and for the greeter above.
  environment.systemPackages = [ pkgs.adwaita-icon-theme ];
}
