{ stdenv, fetchurl }:
stdenv.mkDerivation rec {
  name = "ioncube-loaders";
  src = fetchurl {
    # XXX: "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
    url = "http://archive.intr/downloads/8kfw0iqwksm5568m56lafw9gy7p6ldcq-ioncube_loaders_lin_x86-64.tar.gz";
    sha256 = "0q7wa45rw1np0skp44bp9v1c4pqcr6lmg40yjb7hwm0na0svkk3z";
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
    "v74"
    "v74ts"
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
