{ stdenv, fetchurl, cmake, libiconv, openssl, zlib, rsync }:

stdenv.mkDerivation rec {
  version = "6.1.0";
  name = "mariadb-connector-c-${version}";

  src = fetchurl {
    url = "https://downloads.mysql.com/archives/get/file/mysql-connector-c-6.1.0-src.tar.gz";
    sha256 = "0cifddg0i8zm8p7cp13vsydlpcyv37mz070v6l2mnvy0k8cng2na";
    name   = "mariadb-connector-c-${version}-src.tar.gz";
  };

  # outputs = [ "dev" "out" ]; FIXME: cmake variables don't allow that < 3.0
  cmakeFlags = [
    "-DWITH_EXTERNAL_ZLIB=ON"
    "-DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock"
  ];

  # The cmake setup-hook uses $out/lib by default, this is not the case here.
  preConfigure = stdenv.lib.optionalString stdenv.isDarwin ''
             cmakeFlagsArray+=("-DCMAKE_INSTALL_NAME_DIR=$out/lib/mariadb")
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
