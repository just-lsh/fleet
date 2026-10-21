{ config, ... }:
{
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
      "INTERACTIVE_COMMENTS"
    ];

    shellAliases = {
      ll = "eza -l --git";
      lla = "eza -la --git";
      lt = "eza --tree --level=2";
    };
  };

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
  };

  programs.starship.enable = true;

  programs.zoxide = {
    enable = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  home.sessionVariables._ZO_ECHO = "1";

  programs.nix-your-shell.enable = true;
}
