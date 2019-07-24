{ stdenv }:
stdenv.mkDerivation rec {
  name = "ioncube-loaders";
  src = fetchTarball {
    url = "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz";
  };
  phases = [ "installPhase" ];
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
    cp ${src}/ioncube_loader_lin_* $out
    for each in $outputs
    do
      filename=ioncube_loader_lin_$(echo $each | sed 's/./&./2;s/^v//;s/ts$/_ts/').so
      vout="''${!each}"
      [ -f "${src}/$filename" ] && mkdir $vout && cp ${src}/$filename $vout/ioncube_loader.so
    done
  '';
}
