{
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

  programs.gh.enable = true;
}
