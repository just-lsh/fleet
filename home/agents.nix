{
  programs.claude-code = {
    enable = true;
    package = null;
    mutableSettings = true;
    skills = ./.agents/skills;
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
    skills = ./.agents/skills;
    settings = {
      commit_attribution = "";
      features.memories = false;
      skills.bundled.enabled = false;
    };
  };
}
