{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "zend-optimizer-3.3.9";
  src =  fetchurl {
    url = "http://downloads.zend.com/optimizer/3.3.9/ZendOptimizer-3.3.9-linux-glibc23-x86_64.tar.gz";
    sha256 = "1f7c7p9x9p2bjamci04vr732rja0l1279fvxix7pbxhw8zn2vi1d";
  };
  phases = [ "installPhase" ];
  outputs = [
   "v44"
   "v52"
   "out"
  ];
  installPhase = ''
                 mkdir -p  $v44/ $v52/  $out/
                 tar zxvf  ${src} -C $out/
#                  tar zxvf  ${src} -C $out/ ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/4_4_x_comp/ZendOptimizer.so
                   ls -alah
                  pwd
                   ls -alah ..
                  ls -alh ../build
                  cp -rv $out/ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/4_4_x_comp/ZendOptimizer.so $v44/ZendOptimizer.so
                  cp -rv $out/ZendOptimizer-3.3.9-linux-glibc23-x86_64/data/5_2_x_comp $v52/ZendOptimizer.so
      '';
}
