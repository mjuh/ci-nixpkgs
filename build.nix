let
  overlay = import ./default.nix;
  overlayed = import <nixpkgs> { overlays = [ overlay ]; };
  justOverlayed = (overlay {} overlayed);
  lib = overlayed.lib;
  inherit (lib) collect filterAttrs isDerivation dropAttrs filter attrValues;
in
  collect isDerivation (dropAttrs [ "lib" "dockerTools" "openrestyPackages" ] justOverlayed)
  ++ filter (p: isDerivation p && p.meta.available) (attrValues justOverlayed.openrestyPackages)
