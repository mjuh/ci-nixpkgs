# This file contains machinery to build all packages in the overlay.
# To do that, run:
#
# nix-build build.nix --cores 4 -A nixpkgsUnstable --show-trace
#
# The results are directory hierarchies.

let
  nixpkgsUnstable =
    (import <nixpkgs>
      { overlays = [ (import ./default.nix) ]; }).majordomoPkgs;
in
{
  all = [ nixpkgsUnstable ];
  inherit nixpkgsUnstable;
}
