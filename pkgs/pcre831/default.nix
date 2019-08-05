{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "pcre-8.31";
  src = fetchurl {
    url = "https://ftp.pcre.org/pub/pcre/${name}.tar.bz2";
    sha256 = "0g4c0z4h30v8g8qg02zcbv7n67j5kz0ri9cfhgkpwg276ljs0y2p";
  };
  outputs = [ "out" ];
  configureFlags = ''
          --enable-jit
      '';
}
