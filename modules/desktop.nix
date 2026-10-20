{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./noctalia.nix ];

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
    description = "Install Flow Icons for Zed";
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
    ghostty
    google-chrome
    chatgpt
    zed-editor
    gearlever
    proton-pass-cli
    discord
    raddebugger
    wl-clipboard
  ];
}
