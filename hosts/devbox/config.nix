{
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.disko
    ./disk.nix
    ../../shared/common.nix
  ];

  hardware.facter.reportPath = ./facter.json;

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  programs.nh.clean = {
    dates = lib.mkForce "daily";
    extraArgs = lib.mkForce "--keep 3 --keep-since 7d";
  };

  nix.settings = {
    min-free = 3 * 1024 * 1024 * 1024;
    max-free = 8 * 1024 * 1024 * 1024;
    max-jobs = 1;
    cores = 2;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 180; # swapping to zram is cheap
    "vm.page-cluster" = 0; # no readahead on zram
  };

  systemd.oomd = {
    enableRootSlice = true;
    enableUserSlices = true;
  };

  # Cap login sessions below total RAM so sshd and tailscale stay reachable.
  systemd.slices.user.sliceConfig = {
    MemoryHigh = "3G";
    MemoryMax = "3.4G";
  };

  users.users.len = {
    linger = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBFzAYYUHt43xAQurGUHSLVOCiwlug8JxeFnsaTyMA1"
    ];
  };

  home-manager.users.len = {
    systemd.user.tmpfiles.rules = [
      "e %h/.cache - - - 7d"
      "e %h/.npm/_cacache - - - 7d"
    ];

    # T3 Code never removes old runtimes, and the pnpm store grows unbounded.
    systemd.user.services.disk-cleanup = {
      Unit.Description = "Prune old T3 Code runtimes and unreferenced pnpm packages";
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe (
          pkgs.writeShellApplication {
            name = "disk-cleanup";
            runtimeInputs = with pkgs; [
              coreutils
              findutils
              gnugrep
              jq
              pnpm
            ];
            text = ''
              runtime="$HOME/.t3/runtime"
              if [ -d "$runtime/versions" ]; then
                active=$(jq -r '.activeVersion // empty' "$runtime/service-state.json" 2>/dev/null || true)
                if [ -n "$active" ]; then
                  # Keep the active runtime plus the two newest (rollback target or an in-progress install)
                  keep=$(find "$runtime/versions" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -rV | head -n 2)
                  for dir in "$runtime/versions"/*/; do
                    version=$(basename "$dir")
                    if [ "$version" != "$active" ] && ! grep -qxF "$version" <<<"$keep"; then
                      echo "Removing T3 runtime $version"
                      rm -rf "$dir"
                    fi
                  done
                else
                  echo "No active T3 runtime recorded, skipping runtime cleanup"
                fi
              fi

              pnpm store prune
            '';
          }
        );
      };
    };

    # Shares the desktop session on localhost, reached through an SSH tunnel.
    systemd.user.services.x11vnc = {
      Unit = {
        Description = "VNC server for the desktop session";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.x11vnc} -localhost -forever -shared -nopw";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    systemd.user.timers.disk-cleanup = {
      Unit.Description = "Daily disk cleanup";
      Timer = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };

  services.xserver = {
    enable = true;
    desktopManager.xfce = {
      enable = true;
      enableScreensaver = false;
    };
    serverFlagsSection = ''
      Option "BlankTime" "0"
      Option "StandbyTime" "0"
      Option "SuspendTime" "0"
      Option "OffTime" "0"
    '';
  };

  services.displayManager = {
    defaultSession = "xfce";
    autoLogin = {
      enable = true;
      user = "len";
    };
  };

  environment.xfce.excludePackages = with pkgs; [
    mousepad
    parole
    ristretto
    xfce4-appfinder
    xfce4-screenshooter
    xfce4-taskmanager
  ];

  programs.thunar.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    xdotool
    scrot
  ];

  networking.hostName = "devbox";

  system.stateVersion = "26.05";
}
