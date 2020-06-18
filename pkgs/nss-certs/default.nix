{ stdenv, fetchurl, lib, cacert, openssl, nss, perl }:

with lib;

(cacert.override {
  nss = nss.overrideDerivation (old: rec {
    version = "3.53.1";
    src = fetchurl {
      url = concatStrings [
        "mirror://mozilla/security/nss/releases/NSS_"
        (builtins.replaceStrings [ "." ] [ "_" ] version)
        "_RTM/src/nss-"
        version
        ".tar.gz"
      ];
      sha256 = "05jk65x3zy6q8lx2djj8ik7kg741n88iy4n3bblw89cv0xkxxk1d";
    };
  });
}).overrideDerivation (old: rec {
  installPhase = ''
    mkdir -pv $out/etc/ssl/certs
    cp -v ca-bundle.crt $out/etc/ssl/certs
    # install individual certs in unbundled output
    mkdir -pv $unbundled/etc/ssl/certs
    cp -v *.crt $unbundled/etc/ssl/certs
    for file in ${./ca}/*
    do
        cat "$file" >> $out/etc/ssl/certs/ca-bundle.crt
    done

    cd $unbundled/etc/ssl/certs
    chmod 755 .
    cp ${openssl}/bin/c_rehash .
    chmod a+x ./c_rehash
    ln -s ${openssl}/bin/openssl .
    substituteInPlace c_rehash --replace "/usr/bin/env perl" ${perl}/bin/perl
    export PATH=$PWD:$PATH
    ./c_rehash .
    cd -
    ln -s $unbundled/etc/ssl/certs/ca-bundle.crt $unbundled/etc/ssl/certs/ca-certificates.crt
  '';
})
