{ stdenv, gettext }:

stdenv.mkDerivation rec {
  name = "mjerrors";
  buildInputs = [ gettext ];
  src = fetchGit {
    url = "git@gitlab.intr:shared/http_errors.git";
    ref = "master";
    rev = "f83136c7e6027cb28804172ff3582f635a8d2af7";
  };
  outputs = [ "out" ];
  postInstall = ''
    mkdir $out/html
    cp -pr /tmp/mj_http_errors/* $out/html/
  '';
}
