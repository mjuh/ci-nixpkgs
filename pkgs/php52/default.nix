{ stdenv, lib, fetchurl, coreutils, mariadb, autoconf213, automake, bison, pkgconfig
, apacheHttpd, bzip2, flex, freetype, gettext, glibc, glibcLocales, gmp
, html-tidy, icu, kerberos, libiconv, libjpeg130, libmcrypt, libmhash, libpng-lib-dev
, libxml2, libxslt, pam, pcre, postfix, readline, sqlite, t1lib, zlib, withOpenSSL102, libxpm-lib-dev }:

with lib;

let
  testsToSkip = concatStringsSep " " (import ./tests-to-skip.nix);
  ssl102 = withOpenSSL102;
in

stdenv.mkDerivation rec {
  version = "5.2.17";
  name = "php-${version}";
  srcs = [
    (fetchurl {
      url = "https://museum.php.net/php5/${name}.tar.bz2";
      sha256 = "e81beb13ec242ab700e56f366e9da52fd6cf18961d155b23304ca870e53f116c";
    })
    ./crypt-53-extra
  ];
  sourceRoot = name;

  APXS_MPM = "prefork";
  REPORT_EXIT_STATUS = "1";
  TEST_PHP_ARGS = "-q";
  MYSQL_TEST_SKIP_CONNECT_FAILURE = "0";
  checkTarget = "test";
  doCheck = true;
  enableParallelBuilding = true;
  hardeningDisable = [ "bindnow" ];
  stripDebugList = "bin sbin lib modules";

  patches = [
    ./patch/apxs.patch
    ./patch/backport_crypt_from_php53.patch
    ./patch/disable_SSLv2.patch
    ./patch/fix-exif-buffer-overflow.patch
    ./patch/fix-mysqli-buffer-overflow.patch
    ./patch/fix-pcre-php52.patch
    ./patch/fix-tests.patch
    ./patch/gmp6-compatibility.patch
    ./patch/html-tidy-5.6-compatibility.patch
    ./patch/libxml2-2-9_adapt_documenttype.patch
    ./patch/libxml2-2-9_adapt_node.patch
    ./patch/libxml2-2-9_adapt_simplexml.patch
    ./patch/make-test.patch
    ./patch/mj_engineers_apache2_4_abi_fix.patch
  ];

  checkInputs = [ coreutils mariadb ];

  nativeBuildInputs = [
    autoconf213
    automake
    bison
    pkgconfig
  ];
 
  buildInputs = [
    apacheHttpd.dev
    bzip2.dev
    flex
    freetype.dev
    gettext
    glibc.dev
    glibcLocales
    gmp.dev
    html-tidy
    icu
    kerberos
    libiconv
    libjpeg130
    libmcrypt
    libmhash
    libpng-lib-dev
    libxml2.dev
    libxslt.dev
    pam
    pcre
    postfix
    readline.dev
    sqlite.dev
    ssl102.curl-lib-dev
    ssl102.mariadb-connector-c
    ssl102.openssl-lib-dev
    ssl102.postgresql
    ssl102.uwimap
    t1lib
    libxpm-lib-dev
    zlib.dev
  ];

 configureFlags = [
    "--disable-cgi"
    "--disable-debug"
    "--enable-bcmath"
    "--enable-calendar"
    "--enable-dba"
    "--enable-dom"
    "--enable-exif"
    "--enable-ftp"
    "--enable-gd-native-ttf"
    "--enable-inline-optimization"
    "--enable-libxml"
    "--enable-magic-quotes"
    "--enable-mbstring"
    "--enable-pdo"
    "--enable-soap"
    "--enable-sockets"
    "--enable-sysvsem"
    "--enable-sysvshm"
    "--enable-zip"
    "--with-apxs2=${apacheHttpd.dev}/bin/apxs"
    "--with-bz2=${bzip2.dev}"
    "--with-config-file-scan-dir=/run/php52.d/"
    "--with-curl=${ssl102.curl-lib-dev}"
    "--with-freetype-dir=${freetype.dev}"
    "--with-xpm-dir=${libxpm-lib-dev}"
    "--with-t1lib=${t1lib}"
    "--with-gd"
    "--with-gettext=${glibc.dev}"
    "--with-gmp=${gmp.dev}"
    "--with-imap-ssl"
    "--with-imap=${ssl102.uwimap}"
    "--with-jpeg-dir=${libjpeg130}"
    "--with-libxml-dir=${libxml2.dev}"
    "--with-mcrypt=${libmcrypt}"
    "--with-mhash=${libmhash}"
    "--with-mysql=${ssl102.mariadb-connector-c}"
    "--with-mysqli=${ssl102.mariadb-connector-c}/bin/mysql_config"
    "--with-openssl=${ssl102.openssl-lib-dev}"
    "--with-pdo-mysql=${ssl102.mariadb-connector-c}"
    "--with-pdo-pgsql=${ssl102.postgresql}"
    "--with-pdo-sqlite=${sqlite.dev}"
    "--with-pgsql=${ssl102.postgresql}"
    "--with-png-dir=${libpng-lib-dev}"
    "--with-readline=${readline.dev}"
    "--with-tidy=${html-tidy}"
    "--with-xmlrpc"
    "--with-xsl=${libxslt.dev}"
    "--with-zlib=${zlib.dev}"
  ];

  postUnpack = "cp -vr crypt-53-extra/ext ${name}";

  preConfigure = ''
    for each in main/build-defs.h.in scripts/php-config.in
    do
      substituteInPlace $each                             \
        --replace '@INSTALL_IT@' ""                       \
        --replace '@CONFIGURE_COMMAND@' '(omitted)'       \
        --replace '@CONFIGURE_OPTIONS@' ""                \
        --replace '@PHP_LDFLAGS@' ""
    done
    
    export EXTENSION_DIR=$out/lib/php/extensions
    
    configureFlags+=(                   \
      --with-config-file-path=$out/etc  \
      --includedir=$out/include         \
    )

    rm configure    
    ./buildconf --force
  '';

  preCheck = ''
    ln -s ${coreutils}/bin/* /bin
    rm ${testsToSkip}
    mkdir -p /run/mysqld
    ${mariadb.server}/bin/mysql_install_db
    ${mariadb.server}/bin/mysqld -h ./data --skip-networking &
  '';

  postCheck = ''
    ./sapi/cli/php -r 'if(PHP_ZTS) {echo "Unexpected thread safety detected (ZTS)\n"; exit(1);}'
  '';
}
