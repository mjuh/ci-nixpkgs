{ stdenv, fetchurl, cmake, libiconv, openssl, zlib, rsync }:

stdenv.mkDerivation rec {
  version = "6.1.0";
  name = "mysql-connector-c-${version}";

  src = fetchurl {
    url = "https://downloads.mysql.com/archives/get/p/19/file/mysql-connector-c-6.1.0-src.tar.gz";
    sha256 = "0cifddg0i8zm8p7cp13vsydlpcyv37mz070v6l2mnvy0k8cng2na";
  };

  patches = [
    ./secure_auth.patch
  ];
  # outputs = [ "dev" "out" ]; FIXME: cmake variables don't allow that < 3.0
  cmakeFlags = [
    "-DWITH_EXTERNAL_ZLIB=ON"
    "-DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock"
  ];

  preConfigure = ''
    cp VERSION VERSION.server    
  '';

  nativeBuildInputs = [ cmake rsync ];
  propagatedBuildInputs = [ openssl zlib ];
  buildInputs = [ libiconv ];
  enableParallelBuilding = true;
  postInstall = ''
     mkdir -p $out/share/charsets
     rsync -av ../sql/share/charsets/ $out/share/charsets
    '';
}
