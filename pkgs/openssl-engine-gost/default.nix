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
    # Configuration
    cp ${openssl_1_1.out}/etc/ssl/openssl.cnf .
    chmod +w openssl.cnf
    cat >> openssl.cnf <<EOF
    [openssl_def]
    engines = engine_section

    [engine_section]
    gost = gost_section

    [gost_section]
    engine_id = gost
    dynamic_path = $out/lib/engines-${lib.versions.majorMinor openssl_1_1.version}/gost.so
    default_algorithms = ALL
    CRYPT_PARAMS = id-Gost28147-89-CryptoPro-A-ParamSet
    EOF
    mkdir -p "$out"/etc/ssl
    install -m444 openssl.cnf "$out"/etc/ssl/openssl.cnf
    install -m444 openssl.cnf "$out"/etc/ssl/openssl.cnf.dist

    # Builded directory above current
    cd ..

    # Shared library
    mkdir -p "$out"/lib/engines-${lib.versions.majorMinor openssl_1_1.version}
    install -m444 bin/gost.so "$out"/lib/engines-${lib.versions.majorMinor openssl_1_1.version}/gost.so

    # Binary
    mkdir -p "$bin"/bin
    install -m755 bin/gostsum "$bin"/bin/gostsum
    install -m755 bin/gost12sum "$bin"/bin/gost12sum
  '';
}
