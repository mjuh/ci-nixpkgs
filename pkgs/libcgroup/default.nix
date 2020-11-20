{ stdenv, fetchurl, fetchpatch, pam, yacc, flex, automake113x, autoconf
, autoconf-archive, automake, libtool }:

stdenv.mkDerivation rec {
  pname = "libcgroup";
  version = "master";

  buildInputs =
    [ pam yacc flex automake113x autoconf autoconf-archive automake libtool ];

  src = fetchGit {
    url = "https://github.com/libcgroup/libcgroup";
    ref = "master";
  };

  patches = [ ./fix-loop.patch ];

  preConfigure = "autoreconf -fiv";

  meta = {
    description = "Library and tools to manage Linux cgroups";
    homepage = "http://libcg.sourceforge.net/";
    license = stdenv.lib.licenses.lgpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.thoughtpolice ];
  };
}

