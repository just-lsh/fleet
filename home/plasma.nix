{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    papirus-icon-theme
  ];

  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "Papirus-Dark";
      cursor = {
        theme = "Bibata-Modern-Classic";
        size = 24;
      };
    };

    panels = [
      {
        location = "right";
        height = 44;
        floating = false;
        lengthMode = "fill";
        widgets = [
          {
            kickoff = {
              icon = "nix-snowflake";
              sortAlphabetically = true;
              compactDisplayStyle = true;
              favoritesDisplayMode = "list";
              showButtonsFor.custom = [
                "suspend"
                "hibernate"
                "reboot"
                "shutdown"
              ];
            };
          }
          "org.kde.plasma.pager"
          {
            iconTasks.launchers = [
              "preferred://filemanager"
              "applications:google-chrome.desktop"
              "applications:com.mitchellh.ghostty.desktop"
              "applications:dev.zed.Zed.desktop"
              "applications:t3_code_nightly.desktop"
              "applications:raddbg.desktop"
            ];
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];

    configFile = {
      kdeglobals = {
        General = {
          BrowserApplication = "google-chrome.desktop";
          TerminalApplication = lib.getExe pkgs.ghostty;
          TerminalService = "com.mitchellh.ghostty.desktop";
        };
        KDE.AnimationDurationFactor = 0;
      };

      kwalletrc.Wallet."First Use" = false;
    };
  };
}
