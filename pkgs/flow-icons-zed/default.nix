{
  lib,
  buildNpmPackage,
  fetchurl,
  bash,
  unzip,
  makeWrapper,
  nodejs,
  coreutils,
}:
buildNpmPackage (finalAttrs: {
  pname = "flow-icons-zed";
  # Keep in sync with the `v=` query in flow-icons-download.mjs.
  version = "2.0.10";

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

  npmDepsHash = "sha256-aIXTpS3f359NiaQPJ+FWik+EroxPLcgJfBlbCfMB7iA=";
  dontNpmBuild = true;

  # Public demo build: icon mappings and placeholder SVGs, no licensed icons.
  vsix = fetchurl {
    url = "https://open-vsx.org/api/thang-nm/flow-icons/${finalAttrs.version}/file/thang-nm.flow-icons-${finalAttrs.version}.vsix";
    hash = "sha256-vT9c2T4hI4MYKeoRL5jK4tuxGnwmfDBdMI0nbzsmQHY=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  # Lets patchShebangs point the wrapper script at a store bash.
  buildInputs = [ bash ];

  installPhase = ''
    runHook preInstall

    lib=$out/lib/flow-icons-zed
    install -Dm644 -t $lib flow-icons-download.mjs zed-theme.mjs
    cp -r node_modules $lib/
    substitute extension.toml $lib/extension.toml --subst-var version

    unzip -q $vsix 'extension/*' -d vsix
    mkdir -p $out/share $out/bin
    cp -r vsix/extension $out/share/flow-icons-zed-vscode

    substitute flow-icons-zed.sh $out/bin/flow-icons-zed \
      --subst-var version \
      --subst-var lib \
      --replace-fail @vscode@ $out/share/flow-icons-zed-vscode
    chmod +x $out/bin/flow-icons-zed
    wrapProgram $out/bin/flow-icons-zed \
      --prefix PATH : ${
        lib.makeBinPath [
          nodejs
          coreutils
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Installs the licensed Flow Icons as a Zed dev extension";
    homepage = "https://flow-icons.pages.dev";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    mainProgram = "flow-icons-zed";
  };
})
