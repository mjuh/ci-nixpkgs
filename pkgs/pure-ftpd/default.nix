{ fetchurl, stdenv, openssl, mariadb }:

stdenv.mkDerivation rec {
  name = "pure-ftpd-1.0.49";

  src = fetchurl {
    url = "https://download.pureftpd.org/pub/pure-ftpd/releases/${name}.tar.gz";
    sha256 = "19cjr262n6h560fi9nm7l1srwf93k34bp8dp1c6gh90bqxcg8yvn";
  };
  buildInputs = [ openssl mariadb ];
  configureFlags = ''
    --with-tls
    --with-extauth
    --with-rfc2640
    --with-mysql
    --with-quotas
    --with-uploadscript
    --with-extauth
    --with-altlog
  '';
  enableParallelBuilding = true;
  stripDebugList = "bin sbin lib modules";
}
