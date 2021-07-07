{ stdenv, lib, fetchurl, coreutils, autoconf213, automake, bison, pkgconfig
, apacheHttpd, bzip2, expat, flex, freetype, gettext, glibc, glibcLocales
, html-tidy, icu, kerberos, libiconv, libjpegv6b, libmcrypt, libmhash
, libpng12, libxml2, libxslt, libzip, pam, pcre831, postfix, readline
, sablotron, sqlite, t1lib, xorg, zlib, withOpenSSL102, findutils, gnugrep, gnused, mariadb }:

with lib;

let
  freetype-png12 = freetype.override { libpng = libpng12; };
  ssl102 = withOpenSSL102;
  testsToSkip = concatStringsSep " " (import ./tests-to-skip.nix);
in

stdenv.mkDerivation rec {
  version = "4.4.9";
  name = "php-${version}";
  src = fetchurl {
    url = "https://museum.php.net/php4/${name}.tar.bz2";
    sha256 = "1hjn2sdm8sn8xsd1y5jlarx3ddimdvm56p1fxaj0ydm3dgah5i9a";
  };

  NO_INTERACTION = "yeah!";
  REPORT_EXIT_STATUS = "1";
  checkTarget = "test";
  doCheck = false;
  enableParallelBuilding = true;
  hardeningDisable = [ "bindnow" "format" "fortify" "pic" "pie" "relro" "stackprotector" "strictoverflow" ];
  stripDebugList = "bin sbin lib modules";

  patches = [
    ./patch/apache24.patch
    ./patch/apxs.patch
    ./patch/domxml.patch
    ./patch/openssl.patch
    ./patch/pcre.patch
    ./patch/make-test.patch
    ./patch/fix-tests.patch
  ];

  checkInputs = [ coreutils ];

  nativeBuildInputs = [
    pkgconfig
    autoconf213
    automake
    bison
  ];
  
  buildInputs = [
    apacheHttpd.dev
    bzip2.dev
    expat
    flex
    freetype-png12.dev
    gettext
    glibc.dev
    glibcLocales
    html-tidy
    icu
    icu.dev
    kerberos
    libiconv
    libjpegv6b
    libmcrypt
    libmhash
    libpng12
    libxml2.dev
    libxslt.dev
    libzip
    pam
    pcre831
    postfix
    readline.dev
    sablotron
    sqlite.dev
    ssl102.curl-lib-dev
    ssl102.mariadb-connector-c
    ssl102.openssl-lib-dev
    ssl102.postgresql
    ssl102.uwimap
    t1lib
    xorg.libXpm.dev
    zlib.dev
  ];

  configureFlags = [
    "--disable-debug"
    "--disable-fpm"
    "--disable-maintainer-zts"
    "--disable-memcached-sasl"
    "--disable-phpdbg"
    "--disable-pthreads"
    "--enable-bcmath"
    "--enable-calendar"
    "--enable-dba"
    "--enable-dbase"
    "--enable-dom"
    "--enable-exif"
    "--enable-force-cgi-redirect"
    "--enable-ftp"
    "--enable-gd-native-ttf"
    "--enable-inline-optimization"
    "--enable-local-infile"
    "--enable-magic-quotes"
    "--enable-mbstring=ru"
    "--enable-memory-limit"
    "--enable-opcache"
    "--enable-pdo"
    "--enable-soap"
    "--enable-sockets"
    "--enable-sysvsem"
    "--enable-sysvshm"
    "--enable-timezonedb"
    "--enable-wddx"
    "--enable-xslt"
    "--enable-zip"
    "--with-apxs2=${apacheHttpd.dev}/bin/apxs"
    "--with-bz2=${bzip2.dev}"
    "--with-config-file-scan-dir=/run/php44.d/"
    "--with-curl=${ssl102.curl-lib-dev}"
    "--with-curlwrappers"
    "--with-dbase"
    "--with-dom-xslt=${libxslt.dev}"
    "--with-dom=${libxml2.dev}"
    "--with-expat-dir=${expat}"
    "--with-freetype-dir=${freetype-png12.dev}"
    "--with-gd"
    "--with-gettext=${glibc.dev}"
    "--with-iconv"
    "--with-imap-ssl"
    "--with-imap=${ssl102.uwimap}"
    "--with-jpeg-dir=${libjpegv6b}"
    "--with-kerberos"
    "--with-libzip"
    "--with-mcrypt=${libmcrypt}"
    "--with-mhash=${libmhash}"
    "--with-mysql=${ssl102.mariadb-connector-c}"
    "--with-openssl"
    "--with-pcre-regex=${pcre831}"
    "--with-pdo-pgsql=${ssl102.postgresql}"
    "--with-pdo-sqlite=${sqlite.dev}"
    "--with-pgsql=${ssl102.postgresql}"
    "--with-png-dir=${libpng12}"
    "--with-readline=${readline.dev}"
    "--with-tidy=${html-tidy}"
    "--with-ttf"
    "--with-xsl=${libxslt.dev}"
    "--with-xslt"
    "--with-xslt-sablot=${sablotron}"
    "--with-zlib=${zlib.dev}"
   ];

  preConfigure =  ''
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
    rm ${testsToSkip}
    ${findutils}/bin/find . -name '*.phpt' -not -name bug67761.phpt |  ${findutils}/bin/xargs -P `${coreutils}/bin/nproc` -n1 -I {} bash -c '
            echo "processing: {} "
            ${gnugrep}/bin/grep -q -F -m1 /usr/bin/ && ${gnused}/bin/sed -i {} -e "s:/usr/bin/:/bin/:g"  || true ;
            for PROG in `ls ${coreutils}/bin/* | ${findutils}/bin/xargs -n1 ${coreutils}/bin/basename `;
                do ${gnugrep}/bin/grep -q -F -m1 /bin/$PROG {} && \
                echo "replacing coreutils in {} " && \
                ${gnused}/bin/sed -i {} -e "s:/bin/$PROG:${coreutils}/bin/$PROG:g"  || true ;
            done    
     '
    export MYSQL_UNIX_PORT="$(pwd)/test-mysqld.sock"
    export PDO_MYSQL_TEST_DSN="mysql:dbname=test;unix_socket=$MYSQL_UNIX_PORT"
    export PDO_MYSQL_TEST_SOCKET="$MYSQL_UNIX_PORT"
    export PDO_MYSQL_TEST_PASS=""
    export PDO_MYSQL_TEST_USER="root"
    export PDO_TEST_DSN="mysql:dbname=test;unix_socket=$MYSQL_UNIX_PORT"
    export MYSQL_TEST_SOCKET="$MYSQL_UNIX_PORT"
    export MYSQL_TEST_SKIP_CONNECT_FAILURE=0
    export MYSQL_TEST_HOST="localhost"
    export PATH="$PATH:${coreutils}/bin/"
    ${mariadb.server}/bin/mysql_install_db
    ${mariadb.server}/bin/mysqld -h ./data --socket $MYSQL_UNIX_PORT --skip-networking &
  '';
}
