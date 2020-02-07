{ stdenv, makeWrapper, fetchurl, gcc-unwrapped, glibc, patchelf, unzip  }:

stdenv.mkDerivation rec {
  version = "v2_00_21811";
  pname = "arcconf";

  src = fetchurl {
    url = "http://download.adaptec.com/raid/storage_manager/${pname}_${version}.zip";
    sha256 = "18ya78v5298h4ra5i9sizmnlfyrklqpgm30lv6jzhahpjvacajjb";
  };

  buildInputs = [
    gcc-unwrapped.lib
    glibc
    patchelf
  ];

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];


  sourceRoot = ".";

  buildPhase = ''
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 linux_x64/cmdline/arcconf
    chmod +x linux_x64/cmdline/arcconf
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -pr linux_x64/cmdline/arcconf  $out/bin/arcconf.orig
     makeWrapper $out/bin/arcconf.orig $out/bin/arcconf \
       --set LD_LIBRARY_PATH "${stdenv.lib.makeLibraryPath [ gcc-unwrapped ]}" 
    '';
}
