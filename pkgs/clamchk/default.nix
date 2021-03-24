{ lib, buildGoPackage, fetchgit, cacert }:

buildGoPackage rec {
  name = "clamchk";

  src = ./src ;
  goPackagePath = "gitlab.intr/webservices/clamchk";

  goDeps = ./deps.nix;
  extraSrcs = [
    {
      goPackagePath = "gitlab.intr/go-hms/libs.git";
      src = fetchgit.override { inherit cacert; } {
        url = "https://gitlab.intr/go-hms/libs.git";
        rev = "c02a170040c3debcab9583cd8692f8e8a92055f0";
        sha256 = "1ldqdyw7q8vx5b1caa50maxzvdafd5kp6h7ly10kzhhfghklnrnr";
      };
    }
  ];

  excludedPackages = "test";

}

