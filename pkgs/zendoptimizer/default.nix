{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "zend-optimizer-3.3.9";
  src =  fetchurl {
    url = "http://downloads.zend.com/optimizer/3.3.9/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz";
    sha256 = "1f7c7p9x9p2bjamci04vr732rja0l1279fvxix7pbxhw8zn2vi1d";
  };
  installPhase = ''
                  mkdir -p  $out/
                  tar zxvf  ${src} -C $out/ ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/4_4_x_comp/ZendOptimizer.so
      '';
}
