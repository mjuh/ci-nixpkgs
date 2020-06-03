{ stdenv, perl, nix }:
let name = "cgrouptuner";
in stdenv.mkDerivation {
  inherit name;
  src = ./src;
  installPhase = ''
    mkdir -p $out/bin
    export PATH=${nix}/bin:${perl}/bin:$PATH
    cp -pr $src/* $out/bin/
    patchShebangs $out/bin/*
    chmod +x $out/bin/*
  '';
}
