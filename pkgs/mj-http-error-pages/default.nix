{ stdenv, gettext }:

stdenv.mkDerivation rec {
  name = "mjerrors";
  buildInputs = [ gettext ];
  src = fetchGit {
    url = "https://gitlab.intr/shared/http_errors.git";
    ref = "master";
  };
  outputs = [ "out" ];
  postInstall = ''
    mkdir $out/html
    cp -pr /tmp/mj_http_errors/* $out/html/
  '';
}
