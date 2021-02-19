{ stdenv, makeWrapper, fetchurl, gcc-unwrapped, glibc, patchelf, unzip  }:

stdenv.mkDerivation rec {
  version = "1.15";
  pname = "linpack-xtreme";

  src = fetchurl {
    url = "https://www.ngohq.com/LinpackXtreme.tar.gz";
    sha256 = "0q6ccgpcp1sy75sv59s6dp4mnppfl0xacwv6mgfbhwlb4qpxxz6q";
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
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 linpack-xtreme-1.1.5-amd64/AuthenticAMD
    chmod +x linpack-xtreme-1.1.5-amd64/AuthenticAMD
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -pr linpack-xtreme-1.1.5-amd64/AuthenticAMD $out/bin/AuthenticAMD
     makeWrapper $out/bin/AuthenticAMD $out/bin/linpack_benchmark \
       --set LD_LIBRARY_PATH "${stdenv.lib.makeLibraryPath [ gcc-unwrapped ]}" \
       --set OMP_PLACES CORES \
       --set OMP_PROC_BIND SPREAD \
       --set MKL_DYNAMIC FALSE \
    '';
}
