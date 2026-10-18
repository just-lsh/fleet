mod home
mod secrets

[private]
default:
    @just --list

check:
    nix flake check

fmt:
    nix fmt -- $(git ls-files '*.nix')

switch output="workstation":
    nh os switch {{ justfile_dir() }} -H {{ output }}

boot output="workstation":
    nh os boot {{ justfile_dir() }} -H {{ output }}

test output="workstation":
    nh os test {{ justfile_dir() }} -H {{ output }}

update output="workstation":
    nh os switch {{ justfile_dir() }} -H {{ output }} --update

clean:
    nh clean all --keep 5 --keep-since 30d
