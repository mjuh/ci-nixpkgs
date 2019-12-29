{ stdenv, fetchgit, gettext }:

stdenv.mkDerivation rec {
  name = "mjerrors";
  buildInputs = [ gettext ];
  src = fetchgit {
    url = "https://gitlab.intr/shared/http_errors.git";
    rev = "25b81648ddbb77007540401324e7cc7c3a3d1ce1";
    sha256 = "0nai9z3nzhdllwqi3b2nb15mjyrbfc0jgbpyj86zgrpcl0wfgngx";
  };
  outputs = [ "out" ];
  postInstall = ''
    mkdir $out/html
    cp -pr /tmp/mj_http_errors/* $out/html/
  '';
}
