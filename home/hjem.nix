let
  home = "/home/len";
  repo = toString ./.;

  linkAs = source: target: {
    type = "symlink";
    source = "${repo}/${source}";
    target = "${home}/${target}";
  };

  copyAs = source: target: {
    type = "copy";
    source = "${repo}/${source}";
    target = "${home}/${target}";
    clobber = true;
  };

  link = path: linkAs path path;
  copy = path: copyAs path path;

  linkEach =
    sourceDir: targetDir:
    map (name: linkAs "${sourceDir}/${name}" "${targetDir}/${name}") (
      builtins.attrNames (builtins.readDir (./. + "/${sourceDir}"))
    );
in
{
  version = 3;
  files = builtins.concatLists [
    (map link [
      ".zshrc"
      ".config/git"
      ".config/ghostty"
      ".config/helix"
      ".config/zed"
    ])

    (linkEach ".agents/skills" ".agents/skills")
    (linkEach ".agents/skills" ".claude/skills")

    (map copy [
      ".claude/settings.json"
      ".codex/config.toml"
    ])
  ];
}
