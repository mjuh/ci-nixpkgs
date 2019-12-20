{ stdenv, lib, cacert, openssl }:

with lib;

cacert.overrideDerivation (old: rec {
  installPhase = ''
    mkdir -pv $out/etc/ssl/certs
    cp -v ca-bundle.crt $out/etc/ssl/certs
    # install individual certs in unbundled output
    mkdir -pv $unbundled/etc/ssl/certs
    cp -v *.crt $unbundled/etc/ssl/certs

    cd $unbundled/etc/ssl/certs
    chmod 755 .
    for file in *.pem
    do
      ln -s "$file" "$(${openssl}/bin/openssl x509 -hash -noout -in "$file")".0
    done
    cd -
  '';
})
