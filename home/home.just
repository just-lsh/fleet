[private]
default:
    @just --list home

skills *args="--help":
    pnpx --yes skills@latest {{ args }}
