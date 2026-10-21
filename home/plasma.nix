{ lib, pkgs, ... }:
{
  programs.plasma = {
    enable = true;

    # Anything not set here goes back to Plasma's default on the next login.
    overrideConfig = true;

    kwin.virtualDesktops = {
      number = 1;
      rows = 1;
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
              "applications:systemsettings.desktop"
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
          "org.kde.plasma.showdesktop"
        ];
      }
    ];

    configFile = {
      kdeglobals = {
        General = {
          BrowserApplication = "helium.desktop";
          TerminalApplication = lib.getExe pkgs.ghostty;
          TerminalService = "com.mitchellh.ghostty.desktop";
        };
        KDE.AnimationDurationFactor = 0;
        "KFileDialog Settings" = {
          "Allow Expansion" = false;
          "Automatically select filename extension" = true;
          "Breadcrumb Navigation" = true;
          "Decoration position" = 2;
          "Show Full Path" = false;
          "Show Inline Previews" = true;
          "Show Preview" = false;
          "Show Speedbar" = true;
          "Show hidden files" = false;
          "Sort by" = "Name";
          "Sort directories first" = true;
          "Sort hidden files last" = false;
          "Sort reversed" = false;
          "Speedbar Width" = 140;
          "View Style" = "DetailTree";
        };
      };

      # Keyed by the ID plasma-manager gives the desktop and the workstation's
      # ultrawide; other screens keep the default layout.
      kwinrc."Tiling/Desktop_1/f22364db-4473-4fa9-be12-450fbf94ec09" = {
        padding = 4;
        tiles = builtins.toJSON {
          layoutDirection = "horizontal";
          tiles = [
            { width = 0.25; }
            { width = 0.5; }
            { width = 0.25; }
          ];
        };
      };

      kactivitymanagerdrc.activities."14de3893-ec99-4aa3-a1be-6cc88eb373cc" = "Default";

      kded5rc = {
        Module-browserintegrationreminder.autoload = false;
        Module-device_automounter.autoload = false;
      };

      dolphinrc."KFileDialog Settings" = {
        "Places Icons Auto-resize" = false;
        "Places Icons Static Size" = 22;
      };

      kwalletrc.Wallet."First Use" = false;

      plasma-localerc.Formats.LANG = "en_US.UTF-8";
    };
  };
}
