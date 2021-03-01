{ lib, stdenv, fetchgit, cmake, openssl_1_1 }:

stdenv.mkDerivation {
  name = "openssl-engine-gost";
  version = "1.1.0.3";
  src = fetchgit {
    url = "https://github.com/gost-engine/engine";
    rev = "bad240e1016c8cb2554994eda9f67ea0ad8ee89d";
    sha256 = "1jf016915v0kz47jzjbpf7rhlp1sf25hm96mr6qyk5d4nx51gdpd";
  };
  outputs = [ "out" "bin" ];
  nativeBuildInputs = [ cmake openssl_1_1 ];
  installPhase = ''
    cd ..

    mkdir -p "$out"/lib/engines-${lib.versions.majorMinor openssl_1_1.version}
    install bin/gost.so "$out"/lib/engines-${lib.versions.majorMinor openssl_1_1.version}/gost.so

    mkdir -p "$bin"/bin
    install -m755 bin/gostsum "$bin"/bin/gostsum
    install -m755 bin/gost12sum "$bin"/bin/gost12sum
  '';
}
