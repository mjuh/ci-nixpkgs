{ stdenv, fetchgit, cacert }:

stdenv.mkDerivation rec {
  name = "parser3";
  src = fetchgit.override { inherit cacert; } {
    url = "https://gitlab.intr/webservices/parser-lebedeva.git";
    rev = "9d557f9ee4d018881e481aeb1dab52ea1a9882aa";
    sha256 = "1bv2lwyrz7sjcznpzhq6gb8bgcpmq0335pvjkqlw08ha7f6bbz4m";
  };
  installPhase = ''
    mkdir -p $out
    cp -pr * $out/
  '';
}
