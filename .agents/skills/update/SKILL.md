---
name: update
description: Update the fleet's flake inputs, custom packages, vendored skills and other pins, verified on every host.
disable-model-invocation: true
---

# Update

Bring every **pin** in the fleet up to date: anything that names an exact upstream version, revision or hash. Each step bumps one kind of pin, verifies it, and commits it on its own, so the user can revert a bump without touching the others. Pushing and deploying are the user's: pushing `main` makes comin switch the devbox to it.

## 1. Start clean

Confirm `git status` is clean and on `main`, and note `HEAD` as the base for the report. If the tree is dirty, ask the user before touching it.

## 2. Flake inputs

Run `nix flake update`. Then build every host: list them with `nix eval .#nixosConfigurations --apply builtins.attrNames`, and build each with `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`.

Done when every host builds and its evaluation prints no **warnings**. A renamed or deprecated option, or a package dropped from nixpkgs, is fixed here, at the narrowest scope that covers it (see `AGENTS.md`). `system.stateVersion` and `home.stateVersion` record when each host was installed and stay as they are.

Commit as `chore: update flake inputs`, with the old and new nixpkgs revisions in the body.

## 3. Custom packages

Every package in `pkgs/default.nix` gets checked; the ones below are the current set, so a package missing here gets the same treatment by its own fetcher.

- `raddebugger`: find the newest tag with `git ls-remote --tags https://github.com/EpicGamesExt/raddebugger`. Upstream tags pre-releases, so pick by version, not by GitHub's "latest release". Bump with `nix run nixpkgs#nix-update -- --flake raddebugger --version <version>`.
- `flow-icons-zed`: its icons are fetched at runtime; the pin is its npm lockfile. In `pkgs/flow-icons-zed`, run `nix shell nixpkgs#nodejs -c npm update --package-lock-only`, then set `npmDepsHash` to the output of `nix run nixpkgs#prefetch-npm-deps -- package-lock.json`.

Done when each package is on its newest upstream version and builds with `nix build .#<package>`. Commit each bumped package as `chore(pkgs): update <package> to <version>`.

## 4. Workarounds

A **workaround** is code that exists only because something upstream is broken: every entry in `overlays.modifications`, and every comment that cites an upstream issue or says why a package is overridden (`grep -rn` the `.nix` files for `issue`, `fails`, `lags`, `upstream`).

For each, test whether the reason still holds: build the plain package with `nix build --inputs-from . nixpkgs#<package>`, or check the cited issue with `gh issue view <url>`. Remove a workaround whose reason is gone, then rebuild the hosts that used it.

Done when every workaround is either removed or confirmed still needed. Commit removals as `chore: drop <package> workaround`.

## 5. Vendored skills

Run `just home skills update -p -y`. Done when `home/skills-lock.json` and `home/.agents/skills/` changed together and nothing else did. Skills are instructions agents follow, so read each changed skill's diff and note one line on what changed for the report. Commit as `chore: update vendored skills`.

## 6. OpenBot

`hosts/devbox/openbot.nix` pins an image whose bump migrates OpenBot's database irreversibly. Find the newest release with `gh release list --repo nightly-labs/openbot`. If it is newer, ask the user before bumping: they stop the container and copy `/var/lib/openbot` first, and the bump reaches the devbox as soon as `main` is pushed.

On a yes, bump `version`, the image digest (`nix run nixpkgs#crane -- digest ghcr.io/nightly-labs/openbot:<version>`) and the seccomp hash (`nix store prefetch-file --json <url>`, its `hash`) together. Done when the devbox builds. Commit as `chore(devbox): update openbot to <version>`.

## 7. Verify and report

Build every host again, then run `just check` and `just fmt`. Done when all pass and `just fmt` leaves the tree unchanged.

Report, against the base commit:

- each pin bumped, from and to;
- each fix made for a breaking change or warning;
- each workaround removed or kept, with why;
- the gist of each changed skill;
- anything left for the user: an OpenBot bump declined or pending a backup, and the deploy (`just switch` here, `just deploy <host>` for the others, and a push for the devbox).
