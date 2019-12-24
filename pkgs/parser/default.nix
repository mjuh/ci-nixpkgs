{ stdenv }:

stdenv.mkDerivation rec {
  name = "parser3";
  src = fetchGit {
    url = "git@gitlab.intr:webservices/parser-lebedeva.git";
    ref = "master";
  };
  installPhase = ''
    mkdir -p $out
    cp -pr $src/* $out/
  '';
}
