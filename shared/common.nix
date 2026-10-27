{
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./sops.nix
    ./ssh.nix
    ./cliproxyapi.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "len" ];
    };

    optimise = {
      automatic = true;
      dates = "weekly";
    };
  };

  programs.nh = {
    enable = true;
    flake = "/home/len/fleet";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 30d";
    };
  };

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
    config.allowUnfree = true;
  };

  programs.nix-ld = {
    enable = true;
    # T3 Code downloads a Chrome headless shell for its preview browser that
    # links against these. https://github.com/pingdotgg/t3code/issues/16871
    libraries = with pkgs; [
      alsa-lib
      at-spi2-core
      dbus
      expat
      glib
      libgbm
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxkbcommon
      libxrandr
      nspr
      nss
      systemd
    ];
  };

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # Leaves addresses in place when dhcpcd stops, so dropping it next doesn't
  # take away the addresses NetworkManager shares with it.
  networking.dhcpcd.persistent = true;

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  users.users.len = {
    isNormalUser = true;
    description = "len";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
    overwriteBackup = true;
    users.len = ../home/config.nix;
  };

  environment.localBinInPath = true;

  environment.variables.EDITOR = lib.getExe pkgs.helix;

  users.defaultUserShell = pkgs.zsh;

  programs.zsh.enable = true;

  environment.pathsToLink = [ "/share/zsh" ];

  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    git
    jujutsu
    zsh
    just
    nixd
    nil
    nixfmt
    sops
    nodejs
    pnpm
    python3
    uv
    gcc
    gnumake
    cmake
    pkg-config
    binutils
    gdb
    autoconf
    automake
    libtool
    gnupatch
    file
    curl
    wget
    unzip
  ];
}
