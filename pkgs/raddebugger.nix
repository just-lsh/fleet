{
  lib,
  clangStdenv,
  fetchFromGitHub,
  pkg-config,
  copyDesktopItems,
  makeDesktopItem,
  freetype,
  libx11,
  libxext,
  libxfixes,
  libGL,
}:
clangStdenv.mkDerivation (finalAttrs: {
  pname = "raddebugger";
  version = "0.9.29-alpha";

  src = fetchFromGitHub {
    owner = "EpicGamesExt";
    repo = "raddebugger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IQNicRWKdIamDeQU1RRceRR2QgoUlomQYoeCgepO10w=";
  };

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    freetype
    libx11
    libxext
    libxfixes
    libGL
  ];

  # build.sh shells out to git for the version hash, which the tarball lacks
  postPatch = ''
    patchShebangs build.sh
    substituteInPlace build.sh \
      --replace-fail 'git_hash=$(git describe --always --dirty)' 'git_hash=v${finalAttrs.version}' \
      --replace-fail 'git_hash_full=$(git rev-parse HEAD)' 'git_hash_full=v${finalAttrs.version}'
  '';

  buildPhase = ''
    runHook preBuild
    ./build.sh raddbg radbin radlink release
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/{raddbg,radbin,radlink} -t $out/bin
    install -Dm644 data/logo.png $out/share/icons/hicolor/256x256/apps/raddbg.png
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "raddbg";
      desktopName = "RAD Debugger";
      exec = "raddbg";
      icon = "raddbg";
      categories = [
        "Development"
        "Debugger"
      ];
    })
  ];

  meta = {
    description = "Native, user-mode, multi-process, graphical debugger, with the RAD linker and radbin";
    homepage = "https://github.com/EpicGamesExt/raddebugger";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "raddbg";
  };
})
