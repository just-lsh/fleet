mod home

[private]
default:
    @just --list

check:
    nix flake check

fmt:
    nix fmt -- $(git ls-files '*.nix')

switch output="workstation":
    sudo nixos-rebuild switch --flake {{ justfile_dir() }}#{{ output }}

boot output="workstation":
    sudo nixos-rebuild boot --flake {{ justfile_dir() }}#{{ output }}
