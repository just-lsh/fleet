{ lib, pkgs, ... }:
let
  # Maps every MIME type in a list to one app.
  defaultFor = app: types: lib.genAttrs types (_: app);

  browser = "google-chrome.desktop";
  editor = "dev.zed.Zed.desktop";
  images = "org.kde.gwenview.desktop";
  documents = "okularApplication_pdf.desktop";
  archives = "org.kde.ark.desktop";
  media = "org.kde.haruna.desktop";
in
{
  # Plasma has no video or music player with Elisa excluded.
  home.packages = [ pkgs.haruna ];

  # Read-only, so apps can't register themselves as defaults: URL handlers that
  # apps register on first start have to be added here.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = lib.mkMerge [
      (defaultFor browser [
        "text/html"
        "application/xhtml+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
      ])

      # Most source code is a subtype of text/plain, so it falls through to Zed.
      (defaultFor editor [
        "text/plain"
        "text/markdown"
        "text/x-nix"
        "text/x-shellscript"
        "application/x-shellscript"
        "application/json"
        "application/toml"
        "application/yaml"
        "application/xml"
        "text/xml"
        "application/x-zerosize"
      ])

      (defaultFor images [
        "image/avif"
        "image/bmp"
        "image/gif"
        "image/heif"
        "image/jpeg"
        "image/jxl"
        "image/png"
        "image/svg+xml"
        "image/tiff"
        "image/webp"
      ])

      (defaultFor documents [ "application/pdf" ])

      (defaultFor archives [
        "application/zip"
        "application/x-7z-compressed"
        "application/vnd.rar"
        "application/x-tar"
        "application/x-compressed-tar"
        "application/x-bzip2-compressed-tar"
        "application/x-xz-compressed-tar"
        "application/x-zstd-compressed-tar"
        "application/gzip"
        "application/x-bzip2"
        "application/x-xz"
        "application/zstd"
      ])

      (defaultFor media [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/quicktime"
        "video/mpeg"
        "video/ogg"
        "video/vnd.avi"
        "audio/mpeg"
        "audio/flac"
        "audio/ogg"
        "audio/mp4"
        "audio/aac"
        "audio/vnd.wave"
      ])

      {
        "inode/directory" = "org.kde.dolphin.desktop";
        "x-scheme-handler/t3code" = "com.t3tools.T3Code.desktop";
        "x-scheme-handler/codex" = "chatgpt.desktop";
        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      }
    ];
  };

  # Replaces the list Plasma and the apps wrote before.
  xdg.configFile."mimeapps.list".force = true;
}
