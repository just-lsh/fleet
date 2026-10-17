{ lib, pkgs, ... }:
{
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    optimise = {
      automatic = true;
      dates = "weekly";
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;

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

  environment.localBinInPath = true;

  environment.variables.EDITOR = lib.getExe pkgs.helix;

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    git
    gh
    jujutsu
    zsh
    starship
    eza
    helix
    just
    stow
    nixd
    nil
    nixfmt
    nix-your-shell
  ];
}
