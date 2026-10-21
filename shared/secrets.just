set working-directory := ".."

age_keyfile := "/var/lib/sops-nix/key.txt"

[private]
default:
    @just --list secrets

# Re-encrypt every secret for the recipients in .sops.yaml.
update:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    for file in shared/secrets.yaml hosts/*/secrets.yaml; do
        sops updatekeys --yes "$file"
    done

# Print this machine's host public key, generating the key first if missing.
host:
    #!/usr/bin/env bash
    set -euo pipefail
    age=$(nix build --no-link --print-out-paths nixpkgs#age)
    if ! sudo test -f {{ age_keyfile }}; then
        sudo install -d -m 700 "$(dirname {{ age_keyfile }})"
        sudo "$age/bin/age-keygen" -o {{ age_keyfile }} 2>/dev/null
        sudo chmod 600 {{ age_keyfile }}
    fi
    sudo "$age/bin/age-keygen" -y {{ age_keyfile }}

# Add a host's key to the shared secrets and its own secrets file, then re-encrypt every secret.
add name key:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ ! "{{ key }}" =~ ^age1[a-z0-9]{58}$ ]]; then
        echo "error: '{{ key }}' is not an age public key" >&2
        exit 1
    fi
    if grep -qE '(&{{ name }} |{{ key }})' .sops.yaml; then
        echo "error: {{ name }} or its key is already in .sops.yaml" >&2
        exit 1
    fi
    NAME='{{ name }}' KEY='{{ key }}' nix run nixpkgs#yq-go -- -i '
      .keys += [strenv(KEY)] | .keys[-1] anchor = strenv(NAME) |
      (.creation_rules[] | select(.path_regex == "^shared/secrets\\.yaml$") | .key_groups[].age) += [""] |
      (.creation_rules[] | select(.path_regex == "^shared/secrets\\.yaml$") | .key_groups[].age[-1]) alias = strenv(NAME) |
      .creation_rules += [{"path_regex": "^hosts/" + strenv(NAME) + "/secrets\\.yaml$", "key_groups": [{"age": ["", ""]}]}] |
      .creation_rules[-1].key_groups[0].age[0] alias = "main" |
      .creation_rules[-1].key_groups[0].age[1] alias = strenv(NAME)
    ' .sops.yaml
    just secrets update

# Replace an existing host's public key and re-encrypt every secret.
replace name key:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ ! "{{ key }}" =~ ^age1[a-z0-9]{58}$ ]]; then
        echo "error: '{{ key }}' is not an age public key" >&2
        exit 1
    fi
    if ! grep -qE '&{{ name }} ' .sops.yaml; then
        echo "error: {{ name }} is not in .sops.yaml" >&2
        exit 1
    fi
    NAME='{{ name }}' KEY='{{ key }}' nix run nixpkgs#yq-go -- -i '
      (.keys[] | select(anchor == strenv(NAME))) |= (. = strenv(KEY))
    ' .sops.yaml
    just secrets update
