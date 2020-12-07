{ stdenv, fetchurl, makeWrapper, glibc, patchelf, openssl_1_0_2, fontconfig
, freetype, libjpeg8, libpng12, zlib, icu52, gcc-unwrapped }:

stdenv.mkDerivation {
  name = "phantomjs";
  version = "2.0.0";
  src = fetchurl {
    url =
      "https://github.com/fgrehm/docker-phantomjs2/releases/download/v2.0.0-20150722/dockerized-phantomjs.tar.gz";
    sha256 = "1xscmzywk2sm9sqgjqzg207g3qln0sxygqr84yzpz1sjmwfby3rp";
    name = "phantomjs-2.0.0.tar.gz";
  };
  sourceRoot = ".";
  buildInputs = [ glibc patchelf openssl_1_0_2 ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 usr/local/bin/phantomjs
  '';
  installPhase = ''
    mkdir -p $out/{bin,etc,lib,usr/{lib,share}}
    cp -R etc/fonts $out/etc/
    cp -R lib/* $out/lib/
    cp -R lib64 $out/
    cp -R usr/lib/* $out/usr/lib/
    cp -R usr/lib/x86_64-linux-gnu $out/usr/
    cp -R usr/share/* $out/usr/share/
    cp usr/local/bin/phantomjs $out/bin/.phantomjs-real
    makeWrapper $out/bin/.phantomjs-real $out/bin/phantomjs \
      --set LD_LIBRARY_PATH "${
        stdenv.lib.makeLibraryPath [
          openssl_1_0_2
          fontconfig
          freetype
          libjpeg8
          libpng12
          zlib
          icu52
          gcc-unwrapped.lib
        ]
      }"
  '';
}
