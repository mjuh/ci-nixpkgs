{ stdenv, fetchgit, fetchpatch, pam, yacc, flex, automake113x, autoconf
, autoconf-archive, automake, libtool }:

stdenv.mkDerivation rec {
  pname = "libcgroup";
  version = "0.42.2";
  buildInputs = [ pam yacc flex autoconf autoconf-archive automake libtool ];
  src = fetchgit {
    url = "https://github.com/libcgroup/libcgroup";
    rev = "v" + version;
    sha256 = "16nxvv41clrms75bvhmdn304lj3fhrnivg0hdxj8rjm0a6r99kg1";
  };
  patches = [ ./libcgroup-disable-tests.patch ];
  preConfigure = "autoreconf -fiv";
  meta = {
    description = "Library and tools to manage Linux cgroups";
    homepage = "http://libcg.sourceforge.net/";
    license = stdenv.lib.licenses.lgpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.thoughtpolice ];
  };
}

