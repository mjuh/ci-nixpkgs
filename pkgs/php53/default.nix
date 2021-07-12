{ stdenv, lib, fetchurl, coreutils, mariadb, autoconf213, automake, bison, pkgconfig
, apacheHttpd, bzip2, flex, freetype, gettext, glibc, glibcLocales, gmp, html-tidy
, icu, kerberos, libiconv, libjpeg130, libmcrypt, libmhash, libpng, libsodium
, libxml2, libxslt, pam, pcre-lib-dev, postfix, readline, sqlite, t1lib, zlib, withOpenSSL102, libxpm-lib-dev, findutils, gnugrep, gnused }:

with lib;

let
  testsToSkip = concatStringsSep " " (import ./tests-to-skip.nix);
  ssl102 = withOpenSSL102;
in

stdenv.mkDerivation rec {
  version = "5.3.29";
  name = "php-${version}";
  src = fetchurl {
    url = "https://museum.php.net/php5/${name}.tar.bz2";
    sha256 = "1480pfp4391byqzmvdmbxkdkqwdzhdylj63sfzrcgadjf9lwzqf4";
  };

  REPORT_EXIT_STATUS = "1";
  TEST_PHP_ARGS = "-q";
  MYSQL_TEST_SKIP_CONNECT_FAILURE = "0";
  checkTarget = "test";
  doCheck = false;
  enableParallelBuilding = true;
  hardeningDisable = [ "bindnow" ];
  stripDebugList = "bin sbin lib modules";

  patches = [
    ./patch/apxs.patch
    ./patch/fix-exif-buffer-overflow.patch
    ./patch/fix-mysqli-buffer-overflow.patch
    ./patch/html-tidy-5.6-compatibility.patch
    ./patch/make-test.patch
    ./patch/fix-tests.patch
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
    libpng
    libsodium
    libxml2.dev
    libxslt.dev
    pam
    pcre-lib-dev
    postfix
    readline.dev
    sqlite.dev
    t1lib
    ssl102.curl-lib-dev
    ssl102.mariadb-connector-c
    ssl102.openssl-lib-dev
    ssl102.postgresql
    ssl102.uwimap
    libxpm-lib-dev
    zlib.dev
  ];

  configureFlags = [
    "--enable-​fastcgi"
    "--disable-debug"
    "--disable-fpm"
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
    "--with-config-file-scan-dir=/run/php53.d/"
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
    "--with-png-dir=${libpng.dev}"
    "--with-readline=${readline.dev}"
    "--with-tidy=${html-tidy}"
    "--with-xmlrpc"
    "--with-xsl=${libxslt.dev}"
    "--with-zlib=${zlib.dev}"
    "--with-pcre-regex=${pcre-lib-dev}"
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

  postCheck = ''
    ./sapi/cli/php -r 'if(PHP_ZTS) {echo "Unexpected thread safety detected (ZTS)\n"; exit(1);}'
  '';
}
