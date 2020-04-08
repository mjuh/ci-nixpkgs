# This file contains machinery to build overlay packages.
#
# Build all packages:
# nix-build --show-trace build.nix
#
# Build specific package:
# nix-build --show-trace --arg set true build.nix -A overlay.mjperl5Packages

{ set ? false }:

let
  overlay = import ./default.nix;
  overlayed = import <nixpkgs> { overlays = [ overlay ]; };
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
