#!/usr/bin/env nix-shell
#! nix-shell -E "with import <nixpkgs> { overlays = [(import ./.)]; }; stdenv.mkDerivation { name = \"update-script-php72\"; buildInputs = [bash curl jq gnugrep common-updater-scripts]; }"

set -eu -o pipefail

version=$(curl -s 'https://www.php.net/releases/index.php?json&version=7.3' | jq .version)
update-source-version php73 "$version"
