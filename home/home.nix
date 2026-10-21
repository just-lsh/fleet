{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  # Links each entry of a directory, so the directory itself stays writable.
  # Forced, since directories can't be backed up and hjem left links here.
  linkEach =
    source: target:
    lib.mapAttrs' (name: _: {
      name = "${target}/${name}";
      value = {
        source = source + "/${name}";
        force = true;
      };
    }) (builtins.readDir source);
in
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ./plasma.nix
  ];

  home.stateVersion = "26.11";

  home.packages = [ pkgs.eza ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      path = "${config.home.homeDirectory}/.zsh_history";
      size = 50000;
      save = 50000;
      extended = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };

    setOptions = [
      "HIST_FCNTL_LOCK"
      "HIST_REDUCE_BLANKS"
      "HIST_VERIFY"
      "AUTO_CD"
      "AUTO_PUSHD"
      "PUSHD_IGNORE_DUPS"
      "PUSHD_SILENT"
      "INTERACTIVE_COMMENTS"
    ];

    shellAliases = {
      ls = "eza --icons=auto --color=auto --hyperlink=auto --classify=auto --sort=type --group-directories-first --oneline";
      la = "ls -a";
      ll = "ls -l --git";
      lla = "ls -la --git";
      lt = "ls --tree --level=2";
    };

    initContent = ''
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # Up/Down search history for lines starting with what's already typed
      autoload -U up-line-or-beginning-search down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      [[ -n ''${terminfo[kcuu1]} ]] && bindkey ''${terminfo[kcuu1]} up-line-or-beginning-search
      [[ -n ''${terminfo[kcud1]} ]] && bindkey ''${terminfo[kcud1]} down-line-or-beginning-search
      bindkey '^[[A' up-line-or-beginning-search
      bindkey '^[[B' down-line-or-beginning-search

      # Ctrl+Space accepts the autosuggestion
      bindkey '^ ' autosuggest-accept
    '';
  };

  programs.starship.enable = true;

  programs.zoxide = {
    enable = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.nix-your-shell.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Len";
        email = "just.len.sh@gmail.com";
      };
      init.defaultBranch = "main";
      push = {
        autoSetupRemote = true;
        default = "current";
      };
    };
  };

  # Also sets gh up as git's credential helper for GitHub and Gist.
  programs.gh.enable = true;

  programs.helix = {
    enable = true;
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter = {
          command = "nixfmt";
          args = [
            "--filename=%{buffer_name}"
            "-"
          ];
        };
      }
    ];
  };

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = [
        "JetBrainsMono Nerd Font Mono"
        "Noto Color Emoji"
      ];
      font-size = 14;
      # Targets of the universal Super+C/V remap in keyd
      keybind = [
        "ctrl+insert=copy_to_clipboard"
        "shift+insert=paste_from_clipboard"
      ];
    };
  };

  # Merged into settings.json on every switch, so Zed can still save its own.
  programs.zed-editor = {
    enable = true;
    userSettings = {
      cli_default_open_behavior = "new_window";
      icon_theme = "Flow Deep";
      languages.Nix.formatter.external = {
        command = "nixfmt";
        arguments = [
          "--filename=$ZED_FILENAME"
          "-"
        ];
      };
      buffer_font_family = "JetBrainsMono Nerd Font Mono";
      buffer_font_size = 18;
      theme = "Fleet Dark";
      ui_font_family = "DejaVu Sans";
      ui_font_size = 20;
      agent.button = false;
      collaboration_panel.button = false;
      current_line_highlight = "gutter";
      diagnostics.inline.enabled = true;
      disable_ai = true;
      outline_panel.button = false;
      project_panel = {
        git_status_indicator = true;
        indent_guides.show = "never";
        show_diagnostics = "off";
      };
      scrollbar.show = "never";
      status_bar = {
        active_encoding_button = "enabled";
        active_language_button = false;
        line_endings_button = true;
      };
      tab_bar = {
        show_nav_history_buttons = false;
        show_tab_bar_buttons = false;
      };
      tabs = {
        activate_on_close = "left_neighbour";
        file_icons = true;
      };
      terminal = {
        blinking = "on";
        copy_on_select = true;
        cursor_shape = "bar";
      };
      title_bar = {
        show_branch_status_icon = true;
        show_project_items = false;
        show_sign_in = false;
        show_user_menu = false;
      };
      toolbar = {
        breadcrumbs = false;
        code_actions = false;
        quick_actions = false;
      };
      format_on_save = "on";
    };
  };

  # Claude Code and Codex update themselves in ~/.local/bin, so only their
  # settings are managed, merged in so the apps can still write them.
  programs.claude-code = {
    enable = true;
    package = null;
    mutableSettings = true;
    settings = {
      theme = "dark";
      autoMemoryEnabled = false;
      disableBundledSkills = true;
      attribution = {
        commit = "";
        pr = "";
        sessionUrl = false;
      };
    };
  };

  programs.codex = {
    enable = true;
    package = null;
    mutableSettings = true;
    settings = {
      commit_attribution = "";
      features.memories = false;
      skills.bundled.enabled = false;
    };
  };

  home.file =
    linkEach ./.agents/skills ".agents/skills" // linkEach ./.agents/skills ".claude/skills";

  # The Flow Icons extension without its icons, which the flow-icons service in
  # modules/desktop.nix fills in. Zed treats a linked extension as a dev
  # extension and never replaces it with a registry update.
  xdg.dataFile = {
    "flow-icons/extension/extension.toml".source =
      "${pkgs.flow-icons-zed}/share/flow-icons-zed/extension.toml";
    "zed/extensions/installed/flow-icons".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.dataHome}/flow-icons/extension";
  };
}
