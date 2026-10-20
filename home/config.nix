{ lib, ... }:
let
  # A store copy of this directory, so a new host needs nothing but the flake.
  repo = builtins.path {
    path = ./.;
    name = "home";
  };

  # Copies rather than links, so they stay editable in place. Activation, on
  # every switch and boot, puts back the version from this directory.
  copyAs = source: target: {
    name = target;
    value = {
      type = "copy";
      source = "${repo}/${source}";
      # Store files are read-only.
      permissions = "644";
    };
  };

  copy = path: copyAs path path;

  linkAs = source: target: {
    name = target;
    value.source = "${repo}/${source}";
  };

  filesIn =
    dir:
    map (file: lib.removePrefix "${toString ./.}/${dir}/" (toString file)) (
      lib.filesystem.listFilesRecursive (./. + "/${dir}")
    );

  # Copies a directory file by file. The directory itself is declared too, so
  # it stays real even where an earlier setup left a link in its place.
  copyTreeAs =
    sourceDir: targetDir:
    [
      {
        name = targetDir;
        value.type = "directory";
      }
    ]
    ++ map (file: copyAs "${sourceDir}/${file}" "${targetDir}/${file}") (filesIn sourceDir);

  copyTree = dir: copyTreeAs dir dir;

  # Links each entry of a directory, for content that isn't edited by hand.
  linkEach =
    sourceDir: targetDir:
    map (name: linkAs "${sourceDir}/${name}" "${targetDir}/${name}") (
      builtins.attrNames (builtins.readDir (./. + "/${sourceDir}"))
    );
in
{
  # Declared files always win, without backups.
  clobberFiles = true;

  files = builtins.listToAttrs (
    builtins.concatLists [
      (map copy [
        ".zshrc"
        ".claude/settings.json"
        ".codex/config.toml"
      ])

      (lib.concatMap copyTree [
        ".config/git"
        ".config/ghostty"
        ".config/helix"
        ".config/zed"
        ".config/noctalia"
        ".config/umbriel"
      ])

      (linkEach ".agents/skills" ".agents/skills")
      (linkEach ".agents/skills" ".claude/skills")
    ]
  );
}
