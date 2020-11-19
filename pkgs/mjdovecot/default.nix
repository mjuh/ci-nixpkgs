{ stdenv, lib, fetchurl, perl, pkgconfig, openssl, cyrus_sasl, lua5_3, zlib, bzip2, lz4 }: 

stdenv.mkDerivation rec {
  name = "dovecot";
  version = "2.3.11.3";

  nativeBuildInputs = [ perl pkgconfig ];
  buildInputs = [ openssl cyrus_sasl.dev lua5_3 zlib bzip2 lz4 ];

  src = fetchurl {
    url = "https://dovecot.org/releases/2.3/${name}-${version}.tar.gz";
    sha256 = "1p5gp8jbavcsaara5mfn5cbrnlxssajnchczbgmmfzr7228fmnfk";
  };

  enableParallelBuilding = true;
  installFlags = [ "DESTDIR=$(out)" ];

  postInstall = ''
    cp -r $out/$out/* $out
    rm -rf $out/$(echo "$out" | cut -d "/" -f2)
    ln -s /etc/dovecot/modules/old-stats/libstats_auth.so $out/lib/dovecot/libstats_auth.so
  '';

  preConfigure = ''
    patchShebangs src/config/settings-get.pl
  '';

  patches = [ ./patches/lua.patch ./patches/2.3.x-module_dir.patch ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--with-ssl=openssl"
    "--with-lua=yes"
    "--with-moduledir=/etc/dovecot/modules"
    "--with-zlib"
    "--with-bzlib"
    "--with-lz4"
  ];
}
