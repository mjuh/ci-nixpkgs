let
  overlay = import ./default.nix;
  overlayed = import <nixpkgs> { overlays = [ overlay ]; };
  lib = overlayed.lib;
  inherit (lib) collect filterAttrs isDerivation dropAttrs;
in
  collect isDerivation (dropAttrs [ "lib" "dockerTools" ] (overlay {} overlayed))
