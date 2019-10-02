# This file contains machinery to build all packages in the overlay.
# To do that, run:
#
# nix-build build.nix --cores 4 -A overlay --show-trace
#
# The results are directory hierarchies.

with import <nixpkgs> {};
with lib;

let
  # TODO: convert to callPackages and non-overlay style? more reliable and usable by others, but can cause more pkg dupe?
  overlay = lib.filterAttrs (p: v: p != "luajitPackages")
    (import <nixpkgs> { overlays = [ (import ./default.nix) ]; });
in
{
  all = [ overlay ];
  inherit overlay;
}
