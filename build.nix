# This file contains machinery to build all packages in the overlay.
# To do that, run:
#
# nix-build build.nix --cores 4 -A php73 --show-trace
#
# The results are directory hierarchies.

with <nixpkgs>;
with lib;

import <nixpkgs> { overlays = [ (import ./default.nix) ]; }
