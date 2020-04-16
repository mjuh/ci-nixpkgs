{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  name = "ioncube-loaders";
  src = fetchurl {
    url = "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64_10.3.9.tar.gz";
    sha256 = "1fcbcdcz55b260c7bv3gznpvqgvk0dk7aqh5bszkpj9mg48spdpd";
  };
  phases = [ "unpackPhase" "installPhase" ];
  outputs = [
    "out"
    "v44"
    "v44ts"
    "v52"
    "v52ts"
    "v53"
    "v53ts"
    "v54"
    "v54ts"
    "v55"
    "v55ts"
    "v56"
    "v56ts"
    "v70"
    "v70ts"
    "v71"
    "v71ts"
    "v72"
    "v73"
    "v73ts"
  ];
  installPhase = ''
    mkdir $out
    cp ./ioncube_loader_lin_* $out
    for each in $outputs
    do
      filename=ioncube_loader_lin_$(echo $each | sed 's/./&./2;s/^v//;s/ts$/_ts/').so
      vout="''${!each}"
      [ -f "./$filename" ] && mkdir $vout && cp ./$filename $vout/ioncube_loader.so
    done
  '';
}
