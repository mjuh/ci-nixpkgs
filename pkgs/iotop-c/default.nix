{ stdenv, fetchgit, ncurses, pkg-config }:

stdenv.mkDerivation {
  pname = "iotop-c";
  version = "1.17-1.0ed7202";
  src = fetchgit {
    url = "https://github.com/Tomas-M/iotop";
    rev = "0ed7202b0147eaa895d7d47b326591265c060d62";
    sha256 = "1zcnm71w47n9hsyhad3ipxyaa27hsgx6ydwixhl19jhqv6hws1qm";
  };
  buildInputs = [ ncurses pkg-config ];
  buildPhase = "make DESTDIR=$out";
  installPhase = ''
    make install DESTDIR=$out
    ln -s $out/usr/sbin $out/bin
    mv $out/usr/sbin/iotop $out/usr/sbin/iotopc
  '';
}
