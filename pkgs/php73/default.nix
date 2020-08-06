{ stdenv, lib, fetchurl, coreutils, mariadb, autoconf, automake, bison, pkgconfig
, apacheHttpd, bzip2, curl, expat, flex, freetype, gettext, glibcLocales
, gmp, html-tidy, icu, kerberos, libargon2, libiconv, libjpeg, libmhash, libpng
, libsodium, libwebp, libxml2, libxslt, libzip, openssl, pam
, pcre2, postfix, postgresql, readline, sqlite, t1lib, uwimap, zlib
, libxpm-lib-dev, findutils, gnugrep, gnused, personal ? false, enableFpm ? false }:

with lib;

let
  testsToSkip = concatStringsSep " " (import ./tests-to-skip.nix);
in

stdenv.mkDerivation rec {
  version = "7.3.21";
  name = "php-${version}";
  src = fetchurl {
    url = "http://www.php.net/distributions/${name}.tar.bz2";
    sha256 = "19zpm4sb3a0iv92lcijmvy6c7mmfhdcsrlqxdm6q3cz4wwwymc6v";
  };

  REPORT_EXIT_STATUS = "1";
  TEST_PHP_ARGS = "-q --offline";
  MYSQL_TEST_SKIP_CONNECT_FAILURE = "0";
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

  outputs = [ "out" "junit" ];

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
    icu
    kerberos
    libargon2
    libiconv
    libjpeg.dev
    libmhash
    libpng.dev
    libsodium
    libwebp
    libxml2.dev
    libxslt.dev
    libzip
    openssl
    pam
    pcre2
    postfix
    postgresql
    readline.dev
    sqlite.dev
    t1lib
    uwimap
    libxpm-lib-dev
    zlib.dev
  ];

  configureFlags = [
    "--disable-cgi"
    "--disable-debug"
    "--disable-phpdbg"
    "--enable-bcmath"
    "--enable-calendar"
    "--enable-dba"
    "--enable-dom"
    "--enable-exif"
    "--enable-ftp"
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
    "--with-config-file-scan-dir=/etc/php73.d/"
    "--with-curl=${curl.dev}"
    "--with-freetype-dir=${freetype.dev}"
    "--with-xpm-dir=${libxpm-lib-dev}"
    "--with-gd"
    "--with-gettext=${gettext}"
    "--with-gmp=${gmp.dev}"
    "--with-imap-ssl"
    "--with-imap=${uwimap}"
    "--with-jpeg-dir=${libjpeg.dev}"
    "--with-libxml-dir=${libxml2.dev}"
    "--with-libzip"
    "--with-mhash"
    "--with-mysqli=mysqlnd"
    "--with-openssl"
    "--with-password-argon2=${libargon2}"
    "--with-pcre-jit"
    "--with-pcre-regex=${pcre2.dev}"
    "--with-pdo-mysql=mysqlnd"
    "--with-pdo-pgsql=${postgresql}"
    "--with-pdo-sqlite=${sqlite.dev}"
    "--with-pgsql=${postgresql}"
    "--with-png-dir=${libpng.dev}"
    "--with-readline=${readline.dev}"
    "--with-sodium=${libsodium}"
    "--with-tidy=${html-tidy}"
    "--with-webp-dir=${libwebp}"
    "--with-xmlrpc"
    "--with-xsl=${libxslt.dev}"
    "--with-zlib=${zlib.dev}"
  ] ++ (if enableFpm then ["--enable-fpm"] else ["--disable-fpm"])
    ++ optionals personal [
    "--enable-maintainer-zts"
    "--with-tsrm-pthreads"
  ];

  preConfigure = ''
    TEST_PHP_JUNIT=junit.xml
    export TEST_PHP_JUNIT

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

  postCheck = if personal then "" else ''
    ./sapi/cli/php -r 'if(PHP_ZTS) {echo "Unexpected thread safety detected (ZTS)\n"; exit(1);}'
  '';

  postInstall = ''
    grep PHP_INSTALL_IT $out/include/php/main/build-defs.h 
    sed -i $out/include/php/main/build-defs.h -e '/PHP_INSTALL_IT/d'
    cp junit.xml $junit
  '';
}
