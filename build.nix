#!/usr/bin/env -S nix-build --show-trace --arg set true -A overlay.${PKG}
#
# This file contains machinery to build overlay packages.
#
# Build all packages:
# nix-build --show-trace build.nix
#
# Build specific package:
# nix-build --show-trace --arg set true build.nix -A overlay.mjperl5Packages
# or
# PKG=mjperl5Packages ./build.nix

{ nixpkgs ? (import <nixpkgs> { }).fetchgit {
  url = "https://github.com/NixOS/nixpkgs.git";
  rev = "ce9f1aaa39ee2a5b76a9c9580c859a74de65ead5";
  sha256 = "1s2b9rvpyamiagvpl5cggdb2nmx4f7lpylipd397wz8f0wngygpi";
}, set ? false }:

let
  overlay = import ./default.nix;
  overlayed = import nixpkgs { overlays = [ overlay ]; };
  justOverlayed = (overlay { } overlayed);
  lib = overlayed.lib;
  inherit (lib) collect filterAttrs isDerivation filter attrValues;
in

if set then
  {
    overlay = overlayed;
  }
else
  collect isDerivation (removeAttrs justOverlayed [ "lib" "dockerTools" "openrestyPackages" ])
  ++ filter (p: isDerivation p && p.meta.available) (attrValues justOverlayed.openrestyPackages)
