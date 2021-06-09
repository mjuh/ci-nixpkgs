{ stdenv, fetchurl, apacheHttpd }:

stdenv.mkDerivation rec {
  pname = "mod-fcgid";
  version = "2.3.9";
  src = fetchurl {
    url = "https://www.apache.org/dist/httpd/mod_fcgid/mod_fcgid-${version}.tar.bz2";
    sha256 = "0gqqdz8d762qqmzmkdcyv2p5668f4kwgqmnkdnagrzilir92jb24";
  };
  buildInputs = [ apacheHttpd ];
  configurePhase = ''
    APXS=${apacheHttpd.dev}/bin/apxs DESTDIR="$out" ./configure.apxs
  '';
  installPhase = ''
    make DESTDIR="$out" install
  '';
}
