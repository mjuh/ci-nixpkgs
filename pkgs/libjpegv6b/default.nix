{ stdenv, fetchurl, nasm, libtool, autoconf213, coreutils }:

stdenv.mkDerivation rec {
  name = "libjpeg-6b";
  src = fetchurl {
    url = "http://www.ijg.org/files/jpegsrc.v6b.tar.gz";
    sha256 = "0pg34z6rbkk5kvdz6wirf7g4mdqn5z8x97iaw17m15lr3qjfrhvm";
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
  patches = [
    ./jpeg6b.patch
  ];
}
