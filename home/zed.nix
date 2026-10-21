{ config, pkgs, ... }:
{
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
