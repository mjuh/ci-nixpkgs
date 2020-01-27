let
  overlay = import ./default.nix;
  overlayed = import <nixpkgs> { overlays = [ overlay ]; };
  justOverlayed = (overlay {} overlayed);
  lib = overlayed.lib;
  inherit (lib) collect filterAttrs isDerivation filter attrValues;
in
  collect isDerivation (removeAttrs justOverlayed [ "lib" "dockerTools" "openrestyPackages" ])
  ++ filter (p: isDerivation p && p.meta.available) (attrValues justOverlayed.openrestyPackages)
