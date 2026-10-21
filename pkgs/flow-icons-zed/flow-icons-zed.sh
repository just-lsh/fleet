#!/usr/bin/env bash
# Installs the latest Flow Icons into the Zed extension that Home Manager sets up.
#
# Takes the icon mappings from the latest release of the public VS Code
# extension, downloads that release's licensed SVGs the same way VS Code does,
# then builds the icon theme from both. Downloads only happen once per release,
# so rebuilding the theme stays offline.
#
#   flow-icons-zed LICENSE_FILE

set -euo pipefail

license_file=${1:?usage: flow-icons-zed LICENSE_FILE}
state=${XDG_DATA_HOME:-$HOME/.local/share}/flow-icons
extension=$state/extension

latest=$(curl -fsSL --retry 3 https://open-vsx.org/api/thang-nm/flow-icons)
release=$(jq -er .version <<<"$latest")

if [[ ! -d $state/vscode || "$(cat "$state/version" 2>/dev/null)" != "$release" ]]; then
  download=$state/download
  rm -rf "$download"
  mkdir -p "$download"
  curl -fsSL --retry 3 -o "$download/flow-icons.vsix" "$(jq -er .files.download <<<"$latest")"
  unzip -q "$download/flow-icons.vsix" 'extension/*' -d "$download"
  FLOW_ICONS_LICENSE=$(<"$license_file") \
    node @lib@/flow-icons-download.mjs --release "$release" -o "$download/extension"
  rm -rf "$state/vscode"
  mv "$download/extension" "$state/vscode"
  rm -rf "$download"
  echo "$release" >"$state/version"
fi

rm -rf "$state/theme"
node @lib@/zed-theme.mjs "$state/vscode" "$state/theme"
# Home Manager creates the extension and links its extension.toml; only fill in the rest.
mkdir -p "$extension"
for dir in icons icon_themes; do
  rm -rf "${extension:?}/$dir"
  mv "$state/theme/$dir" "$extension/$dir"
done
rm -rf "$state/theme"
