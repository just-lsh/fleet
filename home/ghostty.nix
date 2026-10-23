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
      theme = "fleet-dark";
    };

    themes.fleet-dark = {
      background = "18191b";
      foreground = "e0e1e4";
      cursor-color = "e0e1e4";
      selection-background = "225090";
      selection-foreground = "e0e1e4";
      palette = [
        "0=#4a4b4d"
        "1=#eb4056"
        "2=#82d2ce"
        "3=#fad075"
        "4=#4b8dec"
        "5=#eb83e2"
        "6=#2ccce6"
        "7=#e0e1e4"
        "8=#4a4b4d"
        "9=#c7001b"
        "10=#009e6f"
        "11=#e09119"
        "12=#0067e6"
        "13=#eb4dde"
        "14=#00bad6"
        "15=#9d9d9f"
      ];
    };
  };
}
