#!/usr/bin/env bash
# Installs Flow Icons as a Zed dev extension.
#
# Downloads the licensed SVGs over the public VS Code extension, the same way
# VS Code does, then builds the Zed extension from it. The download only
# happens once per upstream version, so rebuilding the theme stays offline.
#
#   flow-icons-zed LICENSE_FILE

set -euo pipefail

license_file=${1:?usage: flow-icons-zed LICENSE_FILE}
data=${XDG_DATA_HOME:-$HOME/.local/share}
state=$data/flow-icons
link=$data/zed/extensions/installed/flow-icons

mkdir -p "$state"

if [[ ! -d $state/vscode || "$(cat "$state/version" 2>/dev/null)" != "@version@" ]]; then
  FLOW_ICONS_LICENSE=$(<"$license_file")
  export FLOW_ICONS_LICENSE
  rm -rf "$state/vscode.new"
  cp -r --no-preserve=mode @vscode@ "$state/vscode.new"
  node @lib@/flow-icons-download.mjs -o "$state/vscode.new"
  unset FLOW_ICONS_LICENSE
  rm -rf "$state/vscode"
  mv "$state/vscode.new" "$state/vscode"
  echo "@version@" >"$state/version"
fi

rm -rf "$state/extension.new"
node @lib@/zed-theme.mjs "$state/vscode" "$state/extension.new"
cp --no-preserve=mode @lib@/extension.toml "$state/extension.new/extension.toml"
rm -rf "$state/extension"
mv "$state/extension.new" "$state/extension"

# Zed treats symlinked extensions as dev extensions, which it never auto-updates.
if [[ -e $link && ! -L $link ]]; then
  echo "error: $link exists and is not a symlink; uninstall that extension first" >&2
  exit 1
fi
mkdir -p "$(dirname "$link")"
ln -sfn "$state/extension" "$link"
