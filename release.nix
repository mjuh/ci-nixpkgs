let
  overlay = import ./default.nix;
  overlayed = import <nixpkgs> {
    overlays = [ overlay ];
    inherit (system ? builtins.currentSystem);
  };
  justOverlayed = (overlay { } overlayed);
  lib = overlayed.lib;
  inherit (lib) collect filterAttrs isDerivation dropAttrs filter attrValues;

  drvs = collect isDerivation
    (dropAttrs [ "lib" "dockerTools" "openrestyPackages" ] justOverlayed)
    ++ filter (p: isDerivation p && p.meta.available)
    (attrValues justOverlayed.openrestyPackages);

  jobs = rec {
    build = { system ? builtins.currentSystem }:
      overlayed.releaseTools.nixBuild {
        name = "overlayed";
        src = drvs;
      };
  };

in jobs
