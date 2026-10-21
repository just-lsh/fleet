{
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = [
        "JetBrainsMono Nerd Font Mono"
      ];
      font-size = 14;
      keybind = [
        "ctrl+insert=copy_to_clipboard"
        "shift+insert=paste_from_clipboard"
      ];
    };
  };
}
