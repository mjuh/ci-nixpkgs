{ stdenv, fetchurl, nasm, libtool, autoconf213, coreutils }:

stdenv.mkDerivation rec {
  name = "libjpeg-8";
  src = fetchurl {
    url = "http://www.ijg.org/files/jpegsrc.v8.tar.gz";
    sha256 = "1b0blpk8v397klssk99l6ddsb64krcb29pbkbp8ziw5kmjvsbfhp";
  };
  buildInputs = [ nasm libtool autoconf213 coreutils ];
  doCheck = true;
  checkTarget = "test";
  configureFlags = ''
          --enable-static
          --enable-shared
     '';
  preBuild = ''
          mkdir -p $out/lib
          mkdir -p $out/bin
          mkdir -p $out/man/man1
          mkdir -p $out/include
     '';
  preInstall = ''
          mkdir -p $out/lib
          mkdir -p $out/bin
          mkdir -p $out/man/man1
          mkdir -p $out/include
     '';
}
