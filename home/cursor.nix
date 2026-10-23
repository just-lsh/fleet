{
  pkgs,
  ...
}:
{
  programs.cursor = {
    enable = true;
    profiles.default = {
      extensions = [ pkgs.vscode-extensions.jnoortheen.nix-ide ];
      mutableUserSettings = true;
      userSettings = {
        "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
        "editor.fontFamily" = "'JetBrainsMono Nerd Font Mono'";
        "editor.fontSize" = 18;
        "editor.formatOnSave" = true;
        "editor.minimap.enabled" = false;
        "nix.formatterPath" = "nixfmt";
        "telemetry.telemetryLevel" = "off";
        "terminal.integrated.copyOnSelection" = true;
        "terminal.integrated.cursorBlinking" = true;
        "terminal.integrated.cursorStyle" = "line";
        "update.mode" = "none";
        "window.titleBarStyle" = "custom";
        "workbench.iconTheme" = "flow-deep";
        "workbench.startupEditor" = "none";
      };
    };
  };
}
