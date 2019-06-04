{ stdenv, fetchFromGitHub, skalibs }:

stdenv.mkDerivation rec {
  name = "sockexec";
  version = "3.1.1";
  src = fetchFromGitHub {
    owner = "jprjr";
    repo = "sockexec";
    rev = version;
    sha256 = "1qhk1ysiwzccv7069km26qz2ilph3mzwjqih6czsilsl73ls77xx";
  };
  buildInputs = [ skalibs ];
  configureFlags = [ 
    "--with-sysdeps=${skalibs.lib}/lib/skalibs/sysdeps"
    "--with-lib=${skalibs.lib}/lib"
  ];
  installPhase = ''
    mkdir -p $out/bin
    cp -p sockexec $out/bin
    cp -p sockexec.client $out/bin
  '';
}
