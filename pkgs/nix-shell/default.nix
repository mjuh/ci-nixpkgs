{ }:

with import <nixpkgs> { };

stdenv.mkDerivation {
  name = "nix-flake-environment";
  buildInputs = [
    (import (fetchTarball
      "https://github.com/NixOS/nixpkgs/archive/54756aea9758d4ecd271e377ce16a8b11ccb9554.tar.gz")
      { }).nixUnstable
  ];
}
