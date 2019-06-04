{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "openresty-luajit2";
  version = "2.1-20190507";
  src = fetchFromGitHub {
    owner = "openresty";
    repo = "luajit2";
    rev = "v${version}";
    sha256 = "0vy9kgjh8ihx7qg3qiwnlpqgxh6mpqq25rj96bzj1449fq38xbbq";
  };
  patchPhase = ''
    substituteInPlace Makefile --replace /usr/local "$out"
    substituteInPlace src/Makefile --replace gcc cc
    substituteInPlace Makefile --replace ldconfig ${stdenv.cc.libc.bin or stdenv.cc.libc}/bin/ldconfig
  '';
  configurePhase = false;
  buildFlags = [ "amalg" ];
  enableParallelBuilding = true;
  installPhase   = ''
    make install PREFIX="$out"
    ( cd "$out/include"; ln -s luajit-*/* . )
    ln -s "$out"/bin/luajit-* "$out"/bin/lua
  '';
}
