{ lib, buildGoPackage }:

buildGoPackage rec {
  name = "clamchk";

  src = ./src ;
  goDeps = ./deps.nix;
  goPackagePath = "gitlab.intr/webservices/clamchk";

  excludedPackages = "test";

}

