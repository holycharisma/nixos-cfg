#!/bin/sh

SECRET_FILE="$1"

echo nix-shell -p sops --run \"sops --config .sops.yaml $SECRET_FILE\"