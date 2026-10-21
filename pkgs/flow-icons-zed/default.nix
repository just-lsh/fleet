{
  lib,
  buildNpmPackage,
  bash,
  makeWrapper,
  nodejs,
  coreutils,
  curl,
  jq,
  unzip,
}:
buildNpmPackage {
  pname = "flow-icons-zed";
  # The tooling's own version; the icons always come from the latest release.
  inherit (lib.importJSON ./package.json) version;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./package.json
      ./package-lock.json
      ./flow-icons-download.mjs
      ./zed-theme.mjs
      ./extension.toml
      ./flow-icons-zed.sh
    ];
  };

  npmDepsHash = "sha256-Xvw3DjHRNBj//yggP/3YESqTgBISa+AhsiBR7q8bFc4=";
  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  # Lets patchShebangs point the wrapper script at a store bash.
  buildInputs = [ bash ];

  installPhase = ''
    runHook preInstall

    lib=$out/lib/flow-icons-zed
    install -Dm644 -t $lib flow-icons-download.mjs zed-theme.mjs
    cp -r node_modules $lib/

    # Linked into the extension by Home Manager; see home/zed.nix.
    mkdir -p $out/share/flow-icons-zed
    substitute extension.toml $out/share/flow-icons-zed/extension.toml --subst-var version

    mkdir -p $out/bin
    substitute flow-icons-zed.sh $out/bin/flow-icons-zed --subst-var lib
    chmod +x $out/bin/flow-icons-zed
    wrapProgram $out/bin/flow-icons-zed \
      --prefix PATH : ${
        lib.makeBinPath [
          nodejs
          coreutils
          curl
          jq
          unzip
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Installs the latest licensed Flow Icons into a Zed extension";
    homepage = "https://flow-icons.pages.dev";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "flow-icons-zed";
  };
}
