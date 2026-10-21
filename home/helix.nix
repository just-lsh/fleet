{
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
}
