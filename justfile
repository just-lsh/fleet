mod home 'home/home.just'
mod secrets 'shared/secrets.just'

[private]
default:
    @just --list

check:
    nix flake check

fmt:
    nix fmt -- $(git ls-files '*.nix')

switch output=`uname -n`:
    nh os switch {{ justfile_dir() }} -H {{ output }}

boot output=`uname -n`:
    nh os boot {{ justfile_dir() }} -H {{ output }}

test output=`uname -n`:
    nh os test {{ justfile_dir() }} -H {{ output }}

update output=`uname -n`:
    nh os switch {{ justfile_dir() }} -H {{ output }} --update

# Build a host's configuration here and switch it over SSH.
deploy host target=("len@" + host):
    nh os switch {{ justfile_dir() }} -H {{ host }} --target-host {{ target }}

# Install a host over SSH with nixos-anywhere. Wipes the target's disk.
install host target:
    #!/usr/bin/env bash
    set -euo pipefail
    extra=$(mktemp -d)
    trap 'rm -rf "$extra"' EXIT
    keyfile="$extra/var/lib/sops-nix/key.txt"
    install -d -m 700 "$(dirname "$keyfile")"
    age=$(nix build --no-link --print-out-paths nixpkgs#age)
    "$age/bin/age-keygen" -o "$keyfile" 2>/dev/null
    key=$("$age/bin/age-keygen" -y "$keyfile")
    if grep -qE '&{{ host }} ' .sops.yaml; then
        just secrets replace {{ host }} "$key"
    else
        just secrets add {{ host }} "$key"
    fi
    if [[ ! -f hosts/{{ host }}/id_ed25519.pub ]]; then
        just secrets ssh {{ host }}
    fi
    nix run nixpkgs#nixos-anywhere -- \
        --flake .#{{ host }} \
        --generate-hardware-config nixos-facter hosts/{{ host }}/facter.json \
        --extra-files "$extra" \
        {{ target }}

# Boot the playground VM from the working tree, decrypting secrets with this host's key. Its disk persists in ~/.local/state/fleet/playground.
vm:
    #!/usr/bin/env bash
    set -euo pipefail
    vm=$(nix build --no-link --print-out-paths .#nixosConfigurations.playground.config.system.build.vm)
    mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/fleet/playground"
    keydir="${XDG_RUNTIME_DIR:?}/fleet/playground"
    install -d -m 700 "$keydir"
    trap 'rm -rf "$keydir"' EXIT
    (umask 077 && sudo cat /var/lib/sops-nix/key.txt > "$keydir/key.txt")
    "$vm/bin/run-playground-vm"

clean:
    nh clean all --keep 5 --keep-since 30d
