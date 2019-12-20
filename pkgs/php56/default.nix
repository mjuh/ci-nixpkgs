{ stdenv, lib, fetchurl, symlinkJoin, coreutils, mariadb, autoconf, automake, bison, pkgconfig
, apacheHttpd, bzip2, expat, flex, freetype, gettext, glibc
, glibcLocales, gmp, html-tidy, icu58, kerberos, libiconv, libjpeg
, libmcrypt, libmhash, libpng, libxml2, libxslt, libzip, pam
, pcre-lib-dev, postfix, readline, sqlite, t1lib, xorg, zlib, withOpenSSL102 }:

with lib;

let
  testsToSkip = concatStringsSep " " (import ./tests-to-skip.nix);
  ssl102 = withOpenSSL102;
  gettext-glibc = symlinkJoin {
    name = "gettext-glibc";
    paths = [ gettext glibc.dev ];
  };
in

stdenv.mkDerivation rec {
  version = "5.6.40";
  name = "php-${version}";
  src = fetchurl {
    url = "http://www.php.net/distributions/${name}.tar.bz2";
    sha256 = "005s7w167dypl41wlrf51niryvwy1hfv53zxyyr3lm938v9jbl7z";
  };

  REPORT_EXIT_STATUS = "1";
  TEST_PHP_ARGS = "-q --offline";
  checkTarget = "test";
  doCheck = true;
  enableParallelBuilding = true;
  hardeningDisable = [ "bindnow" ];
  stripDebugList = "bin sbin lib modules";

  patches = [
    ./patch/apxs.patch
    ./patch/html-tidy-5.6-compatibility.patch
    ./patch/fix-tests.patch
  ];

  checkInputs = [ coreutils mariadb ];

  nativeBuildInputs = [
    autoconf
    automake
    bison
    pkgconfig
  ];

  buildInputs = [
    apacheHttpd.dev
    bzip2.dev
    expat
    flex
    freetype.dev
    gettext-glibc
    glibcLocales
    gmp
    html-tidy
    icu58
    kerberos
    libiconv
    libjpeg.dev
    libmcrypt
    libmhash
    libpng
    libxml2.dev
    libxslt.dev
    libzip
    pam
    pcre-lib-dev
    postfix
    readline.dev
    sqlite.dev
    ssl102.curl-lib-dev
    ssl102.mariadb-connector-c
    ssl102.openssl-lib-dev
    ssl102.postgresql
    ssl102.uwimap
    t1lib
    xorg.libXpm
    zlib.dev
  ];

  configureFlags = [
    "--disable-cgi"
    "--disable-debug"
    "--disable-fpm"
    "--disable-phpdbg"
    "--enable-bcmath"
    "--enable-calendar"
    "--enable-dba"
    "--enable-dom"
    "--enable-exif"
    "--enable-ftp"
    "--enable-gd-native-ttf"
    "--enable-inline-optimization"
    "--enable-intl"
    "--enable-libxml"
    "--enable-mbstring"
    "--enable-opcache"
    "--enable-pdo"
    "--enable-soap"
    "--enable-sockets"
    "--enable-sysvsem"
    "--enable-sysvshm"
    "--enable-zip"
    "--with-apxs2=${apacheHttpd.dev}/bin/apxs"
    "--with-bz2=${bzip2.dev}"
    "--with-config-file-scan-dir=/etc/php56.d/"
    "--with-curl=${ssl102.curl-lib-dev}"
    "--with-freetype-dir=${freetype.dev}"
    "--with-gd"
    "--with-gettext=${gettext-glibc}"
    "--with-gmp=${gmp.dev}"
    "--with-imap-ssl"
    "--with-imap=${ssl102.uwimap}"
    "--with-jpeg-dir=${libjpeg.dev}"
    "--with-libxml-dir=${libxml2.dev}"
    "--with-libzip"
    "--with-mcrypt=${libmcrypt}"
    "--with-mhash"
    "--with-mysql=${ssl102.mariadb-connector-c}"
    "--with-mysqli=${ssl102.mariadb-connector-c}/bin/mysql_config"
    "--with-openssl=${ssl102.openssl-lib-dev}"
    "--with-pcre-regex=${pcre-lib-dev}"
    "--with-pdo-mysql=${ssl102.mariadb-connector-c}"
    "--with-pdo-pgsql=${ssl102.postgresql}"
    "--with-pdo-sqlite=${sqlite.dev}"
    "--with-pgsql=${ssl102.postgresql}"
    "--with-png-dir=${libpng.dev}"
    "--with-readline=${readline.dev}"
    "--with-tidy=${html-tidy}"
    "--with-xmlrpc"
    "--with-xsl=${libxslt.dev}"
    "--with-zlib=${zlib.dev}"
  ];

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
