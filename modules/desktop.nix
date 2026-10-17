{ pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;

  services.displayManager.plasma-login-manager.enable = true;

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

  environment.systemPackages = with pkgs; [
    ghostty
    google-chrome
    zed-editor
    gearlever
    proton-pass-cli
  ];
}
