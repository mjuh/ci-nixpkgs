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
    for benchmark in AuthenticAMD GenuineIntel;
    do
      patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 linpack-xtreme-1.1.5-amd64/$benchmark
      chmod +x linpack-xtreme-1.1.5-amd64/$benchmark
    done
  '';

  installPhase = ''
    mkdir -p $out/bin
    for benchmark in AuthenticAMD GenuineIntel;
    do
      cp -pr linpack-xtreme-1.1.5-amd64/$benchmark $out/bin/$benchmark

       makeWrapper $out/bin/$benchmark $out/bin/linpack_benchmark_$benchmark \
         --set LD_LIBRARY_PATH "${stdenv.lib.makeLibraryPath [ gcc-unwrapped ]}" \
         --set OMP_PLACES CORES \
         --set OMP_PROC_BIND SPREAD \
         --set MKL_DYNAMIC FALSE
    done
  '';
}
