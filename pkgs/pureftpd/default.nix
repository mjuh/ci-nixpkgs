{ fetchurl, stdenv, openssl }:

stdenv.mkDerivation rec {
  name = "pure-ftpd-1.0.47";
  src = fetchurl {
    url = "https://download.pureftpd.org/pub/pure-ftpd/releases/${name}.tar.gz";
    sha256 = "1b97ixva8m10vln8xrfwwwzi344bkgxqji26d0nrm1yzylbc6h27";
  };
  buildInputs = [ openssl ];
  configureFlags = ''
    --with-tls
    --with-extauth
    --with-rfc2640
  '';
  enableParallelBuilding = true;
  stripDebugList = "bin sbin lib modules";
}
