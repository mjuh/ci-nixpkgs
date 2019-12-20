{ stdenv, lib, fetchurl, coreutils, mariadb, autoconf, automake, bison, pkgconfig
, apacheHttpd, bzip2, curl, expat, flex, freetype, gettext, glibcLocales
, gmp, html-tidy, icu58, kerberos, libiconv, libjpeg, libmcrypt, libmhash
, libpng, libwebp, libxml2, libxslt, libzip, mariadbConnectorC, openssl, pam
, pcre-lib-dev, postfix, postgresql, readline, sqlite, t1lib, uwimap, xorg, zlib }: 

with lib;

let
  testsToSkip = concatStringsSep " " (import ./tests-to-skip.nix);
in

stdenv.mkDerivation rec {
  version = "7.1.33";
  name = "php-${version}";
  src = fetchurl {
    url = "http://www.php.net/distributions/${name}.tar.bz2";
    sha256 = "0jsgiwawlais8s1l38lz51h1x2ci5ildk0ksfdmkg6xpwbrfb9cm";
  };

  REPORT_EXIT_STATUS = "1";
  TEST_PHP_ARGS = "-q --offline";
  checkTarget = "test";
  doCheck = true;
  enableParallelBuilding = true;
  hardeningDisable = [ "bindnow" ];
  stripDebugList = "bin sbin lib modules";

  patches = [
    ./patch/fix-paths.patch
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
    curl.dev
    expat
    flex
    freetype.dev
    gettext
    glibcLocales
    gmp.dev
    html-tidy
    icu58
    kerberos
    libiconv
    libjpeg.dev
    libmcrypt
    libmhash
    libpng.dev
    libwebp
    libxml2.dev
    libxslt.dev
    libzip
    mariadbConnectorC
    openssl
    pam
    pcre-lib-dev
    postfix
    postgresql
    readline.dev
    sqlite.dev
    t1lib
    uwimap
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
    "--with-config-file-scan-dir=/etc/php71.d/"
    "--with-curl=${curl.dev}"
    "--with-freetype-dir=${freetype.dev}"
    "--with-gd"
    "--with-gettext=${gettext}"
    "--with-gmp=${gmp.dev}"
    "--with-imap-ssl"
    "--with-imap=${uwimap}"
    "--with-jpeg-dir=${libjpeg.dev}"
    "--with-libxml-dir=${libxml2.dev}"
    "--with-libzip"
    "--with-mcrypt=${libmcrypt}"
    "--with-mhash"
    "--with-mysqli=${mariadbConnectorC}/bin/mysql_config"
    "--with-openssl"
    "--with-pcre-jit"
    "--with-pcre-regex=${pcre-lib-dev}"
    "--with-pdo-mysql=${mariadbConnectorC}"
    "--with-pdo-pgsql=${postgresql}"
    "--with-pdo-sqlite=${sqlite.dev}"
    "--with-pgsql=${postgresql}"
    "--with-png-dir=${libpng.dev}"
    "--with-readline=${readline.dev}"
    "--with-tidy=${html-tidy}"
    "--with-webp-dir=${libwebp}"
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
