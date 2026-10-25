# Fleet - Agent instructions

A NixOS flake that declares every machine one person owns, down to the desktop. Each host is a `nixosConfigurations` output named after its hostname. The user's environment comes from Home Manager, the Plasma desktop from plasma-manager, secrets from sops-nix, and fresh installs from disko with nixos-anywhere.

## Where a change goes

Place every change by its _scope_: the narrowest layer that covers every machine it should reach.

- `hosts/<host>/` holds what only that machine gets: hardware, disk layout, boot, and per-host overrides. A host-only Home Manager setting goes here too, under `home-manager.users.<user>`.
- `shared/` holds NixOS modules that hosts import, plus the secrets every host reads.
- `home/` holds the Home Manager configuration every host gives the user. `home/desktop.nix` holds the part only desktop hosts get; `shared/desktop.nix` imports it.
- `pkgs/` holds packages built here; the overlay in `overlays/` puts them into `pkgs`.
- `assets/` holds files referenced from the configuration, such as images.

Plasma settings belong in Nix: plasma-manager owns the Plasma config and resets whatever was changed in the GUI.

## Secrets

Secrets are sops-encrypted YAML. `shared/secrets.yaml` is encrypted for every host; `hosts/<host>/secrets.yaml` only for that host. In both cases the admin key can decrypt too. `.sops.yaml` maps each path to its recipients. Change recipients with the `just secrets` recipes, which also re-encrypt the files. Keep plaintext secrets out of the repo and out of the Nix store; reference them through `config.sops.secrets.<name>.path`.

## Commands

`just` is the entry point. `just --list --list-submodules` shows every recipe. Recipes that touch a machine (`switch`, `boot`, `install`, the `secrets` recipes) are the user's to run. To verify a change, build the affected host with `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`, and use `just check` and `just fmt`.

## Gotchas

- The flake sees only files git tracks. `git add` a new file before evaluating, or Nix reports it missing.
- `hosts/<host>/facter.json` is a generated hardware report. Treat it as read-only input.
- `home/.agents/skills/` is vendored from upstream repos and pinned in the skills lock files. Change it through `just home skills`.

## Commits

Use Conventional Commits (`feat:`, `fix:`, `chore:`), with a lowercase imperative summary.
