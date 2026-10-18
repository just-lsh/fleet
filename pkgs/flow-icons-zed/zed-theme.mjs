#!/usr/bin/env node
// Build the Zed icon theme from an extracted Flow Icons VS Code extension.
//
// Mirrors how the VS Code extension builds its own themes: icons.json maps icon
// names to file extensions, file names and folder names, define.json holds the
// optional icon packs, and settings.json says which packs are on by default.
//
//   node zed-theme.mjs VSCODE_DIR OUT_DIR

import { cpSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";

const PALETTES = [
  { id: "dim", name: "Flow Dim" },
  { id: "deep", name: "Flow Deep" },
  { id: "dawn", name: "Flow Dawn" },
  { id: "you", name: "Flow You" },
];

const FOLDER_PREFIX = "folder_";
const DEFAULT_FOLDER = "gray";

const [srcDir, outDir] = process.argv.slice(2);
if (!srcDir || !outDir) {
  console.error("usage: node zed-theme.mjs VSCODE_DIR OUT_DIR");
  process.exit(1);
}

const readJson = (name) => JSON.parse(readFileSync(path.join(srcDir, name), "utf8"));

// Adds the default-on packs from define.json, like the VS Code extension does.
function loadIcons() {
  const icons = readJson("icons.json");
  const define = readJson("define.json");
  const settings = readJson("settings.json");
  for (const [pack, enabled] of Object.entries(settings.defaults?.packs ?? {})) {
    if (!enabled) continue;
    for (const name of settings.packs?.[pack] ?? []) {
      if (name.startsWith(FOLDER_PREFIX)) {
        const folder = name.slice(FOLDER_PREFIX.length);
        if (define.folders?.[folder]) icons.folders[folder] = define.folders[folder];
      } else if (define.files?.[name]) {
        icons.files[name] = define.files[name];
      }
    }
  }
  return icons;
}

function buildTheme(icons, dir, name, appearance) {
  let missing = 0;
  const iconPath = (icon) => {
    if (!existsSync(path.join(srcDir, dir, `${icon}.svg`))) return null;
    return `./icons/${dir}/${icon}.svg`;
  };
  const folderIcons = (folder) => {
    const collapsed = iconPath(`${FOLDER_PREFIX}${folder}`);
    const expanded = iconPath(`${FOLDER_PREFIX}${folder}_open`);
    return collapsed && expanded ? { collapsed, expanded } : null;
  };

  const file_icons = { default: { path: iconPath("file") } };
  const file_stems = {};
  const file_suffixes = {};
  for (const [icon, match] of Object.entries(icons.files)) {
    const p = iconPath(icon);
    if (!p) {
      missing++;
      continue;
    }
    file_icons[icon] = { path: p };
    for (const n of match?.n ?? []) file_stems[n] = icon;
    for (const e of match?.e ?? []) file_suffixes[e] = icon;
  }

  const named_directory_icons = {};
  for (const [folder, match] of Object.entries(icons.folders)) {
    const p = folderIcons(folder);
    if (!p) {
      missing++;
      continue;
    }
    for (const n of match?.n ?? []) named_directory_icons[n] = p;
  }

  if (missing) console.warn(`${name}: skipped ${missing} icons with no SVG`);
  return {
    name,
    appearance,
    directory_icons: folderIcons(DEFAULT_FOLDER),
    named_directory_icons,
    file_stems,
    file_suffixes,
    file_icons,
  };
}

const icons = loadIcons();
const themes = [];
for (const { id, name } of PALETTES) {
  for (const [dir, themeName, appearance] of [
    [id, name, "dark"],
    [`${id}-light`, `${name} Light`, "light"],
  ]) {
    cpSync(path.join(srcDir, dir), path.join(outDir, "icons", dir), { recursive: true });
    themes.push(buildTheme(icons, dir, themeName, appearance));
  }
}

mkdirSync(path.join(outDir, "icon_themes"), { recursive: true });
writeFileSync(
  path.join(outDir, "icon_themes", "flow-icons.json"),
  `${JSON.stringify({ $schema: "https://zed.dev/schema/icon_themes/v0.3.0.json", name: "Flow Icons", author: "Thang Nguyen", themes }, null, 2)}\n`,
);
console.log(`wrote ${themes.length} themes, ${Object.keys(icons.files).length} file icons, ${Object.keys(icons.folders).length} folder icons`);
