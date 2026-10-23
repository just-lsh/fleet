let
  fg = foreground: { inherit foreground; };
  bold = foreground: {
    inherit foreground;
    is_bold = true;
  };

  # Fleet Dark from the Zed Fleet Themes extension.
  text = "#E0E1E4";
  muted = "#909194";
  faint = "#6E747B";
  blue = "#87C3FF";
  cyan = "#82D2CE";
  yellow = "#EBC88D";
  green = "#A8CC7C";
  pink = "#E394DC";
  purple = "#AF9CFF";
  red = "#E1465E";
in
{
  programs.eza = {
    enable = true;
    icons = "auto";
    colors = "auto";
    extraOptions = [
      "--hyperlink=auto"
      "--classify=auto"
      "--sort=type"
      "--group-directories-first"
      "--oneline"
    ];
    theme = {
      colourful = true;

      filekinds = {
        normal = fg text;
        directory = bold blue;
        symlink = fg cyan;
        pipe = fg yellow;
        block_device = bold yellow;
        char_device = bold yellow;
        socket = bold pink;
        special = fg yellow;
        executable = bold green;
        mount_point = bold blue // {
          is_underline = true;
        };
      };

      perms = {
        user_read = bold yellow;
        user_write = bold pink;
        user_execute_file = bold green;
        user_execute_other = bold green;
        group_read = fg yellow;
        group_write = fg pink;
        group_execute = fg green;
        other_read = fg yellow;
        other_write = fg pink;
        other_execute = fg green;
        special_user_file = fg purple;
        special_other = fg purple;
        attribute = fg muted;
      };

      size = {
        major = fg purple;
        minor = fg purple;
        number_byte = fg text;
        number_kilo = fg text;
        number_mega = fg yellow;
        number_giga = fg pink;
        number_huge = bold red;
        unit_byte = fg muted;
        unit_kilo = fg muted;
        unit_mega = fg muted;
        unit_giga = fg muted;
        unit_huge = fg muted;
      };

      users = {
        user_you = bold yellow;
        user_root = bold red;
        user_other = fg text;
        group_yours = fg yellow;
        group_root = fg red;
        group_other = fg text;
      };

      links = {
        normal = fg cyan;
        multi_link_file = bold cyan;
      };

      # Zed's version control colors.
      git = {
        new = fg "#69B090";
        modified = fg "#71A3EF";
        deleted = fg "#F87C88";
        renamed = fg "#2A7DEB";
        typechange = fg purple;
        ignored = fg faint;
        conflicted = fg red;
      };

      git_repo = {
        branch_main = fg cyan;
        branch_other = fg purple;
        git_clean = fg "#69B090";
        git_dirty = fg "#71A3EF";
      };

      security_context = {
        colon = fg faint;
        user = fg text;
        role = fg purple;
        typ = fg muted;
        range = fg purple;
      };

      file_type = {
        image = fg pink;
        video = bold pink;
        music = fg cyan;
        lossless = bold cyan;
        crypto = bold red;
        document = fg yellow;
        compressed = fg purple;
        temp = fg faint;
        compiled = fg muted;
        build = bold yellow // {
          is_underline = true;
        };
        source = fg text;
      };

      punctuation = fg faint;
      date = fg blue;
      inode = fg muted;
      blocks = fg muted;
      header = fg text // {
        is_underline = true;
      };
      octal = fg purple;
      flags = fg muted;
      symlink_path = fg cyan;
      control_char = fg red;
      broken_symlink = fg red;
      broken_path_overlay = {
        is_underline = true;
      };
    };
  };
}
