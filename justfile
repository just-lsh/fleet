[private]
default:
    @just --list

check:
    nix flake check

fmt:
    nix fmt -- $(git ls-files '*.nix' ':!:hosts/*/hardware.nix')

switch output="len-desktop":
    sudo nixos-rebuild switch --flake {{ justfile_dir() }}#{{ output }}

boot output="len-desktop":
    sudo nixos-rebuild boot --flake {{ justfile_dir() }}#{{ output }}
