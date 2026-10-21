{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.desktopManager.plasma6.enable = true;

  services.displayManager.plasma-login-manager.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    kate
    ktexteditor
    elisa
    khelpcenter
    krdp
    kwin-x11
    plasma-keyboard
    qtvirtualkeyboard
    plasma-browser-integration
    qrca
    union
  ];

  programs.kde-pim.enable = false;

  # The login screen runs as its own user, so it only sees system-wide defaults
  # and packages. Matches the cursor set for len in home/plasma.nix.
  environment.etc."xdg/kcminputrc".text = lib.generators.toINI { } {
    Mouse = {
      cursorTheme = "Bibata-Modern-Classic";
      cursorSize = 24;
    };
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts-color-emoji
  ];

  programs.steam.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.variables.VISUAL = "${lib.getExe pkgs.zed-editor} --wait";

  sops.secrets.flow-icons-license.owner = "len";

  systemd.user.services.flow-icons = {
    description = "Install the latest Flow Icons for Zed";
    wantedBy = [ "default.target" ];
    unitConfig.ConditionUser = "len";
    startLimitIntervalSec = 60 * 60;
    startLimitBurst = 5;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe pkgs.flow-icons-zed} ${config.sops.secrets.flow-icons-license.path}";
      Restart = "on-failure";
      RestartSec = "1min";
    };
  };

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "com.mitchellh.ghostty.desktop" ];
  };

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        meta = {
          c = "C-insert";
          v = "S-insert";
          x = "C-x";
        };
        "control+meta".v = "M-v";
      };
    };
  };

  # Lets the tray toggle the connection and switch exit nodes without root
  services.tailscale.extraSetFlags = [ "--operator=len" ];

  # Mirrors upstream's tailscale-systray.service, bound to the desktop session
  systemd.user.services.tailscale-systray = {
    description = "Tailscale System Tray";
    documentation = [ "https://tailscale.com/kb/1597/linux-systray" ];
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${lib.getExe config.services.tailscale.package} systray";
  };

  environment.systemPackages = with pkgs; [
    bibata-cursors
    google-chrome
    chatgpt
    gearlever
    proton-pass-cli
    discord
    raddebugger
    wl-clipboard
  ];
}
