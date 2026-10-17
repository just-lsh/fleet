{ lib, pkgs, ... }:
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

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.variables.VISUAL = "${lib.getExe pkgs.zed-editor} --wait";

  xdg.terminal-exec = {
    enable = true;
    settings.default = [ "com.mitchellh.ghostty.desktop" ];
  };

  environment.etc."xdg/kdeglobals".text = lib.generators.toINI { } {
    General = {
      TerminalApplication = lib.getExe pkgs.ghostty;
      TerminalService = "com.mitchellh.ghostty.desktop";
    };
  };

  environment.systemPackages = with pkgs; [
    ghostty
    google-chrome
    chatgpt
    zed-editor
    gearlever
    proton-pass-cli
  ];
}
