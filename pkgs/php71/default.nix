{ stdenv, lib, fetchurl, coreutils, mariadb, autoconf, automake, bison, pkgconfig
, apacheHttpd, bzip2, curl, expat, flex, freetype, gettext, glibcLocales
, gmp, html-tidy, icu58, kerberos, libiconv, libjpeg, libmcrypt, libmhash
, libpng, libwebp, libxml2, libxslt, libzip, openssl, pam
, pcre-lib-dev, postfix, postgresql, readline, sqlite, t1lib, uwimap, zlib
, libxpm-lib-dev, findutils, gnugrep, gnused, updateScript }:

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
  MYSQL_TEST_SKIP_CONNECT_FAILURE = "0";
  checkTarget = "test";
  doCheck = false;
  enableParallelBuilding = true;
  hardeningDisable = [ "bindnow" ];
  stripDebugList = "bin sbin lib modules";

  passthru.updateScript = updateScript { inherit name version lib; };

  patches = [
    ./patch/fix-paths.patch
    ./patch/fix-tests.patch
  ];

  checkInputs = [ coreutils mariadb ];

  outputs = [ "out" ];

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
    openssl
    pam
    pcre-lib-dev
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
    "--with-xpm-dir=${libxpm-lib-dev}"
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
    "--with-mysqli=mysqlnd"
    "--with-openssl"
    "--with-pcre-jit"
    "--with-pcre-regex=${pcre-lib-dev}"
    "--with-pdo-mysql=mysqlnd"
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
    echo "fixing openssl tests"
    ${openssl}/bin/openssl genrsa -out ./ext/openssl/tests/bug54992-ca.key 4096
    ${openssl}/bin/openssl req -new -x509 -key ./ext/openssl/tests/bug54992-ca.key \
      -out ext/openssl/tests/bug54992-ca.pem \
      -subj '/C=PT/ST=Lisboa/L=Lisboa/O=PHP Foundation/CN=Root CA for PHP Tests/emailAddress=internals@lists.php.net' \
      -days 400
    ${openssl}/bin/openssl rsa -in ext/openssl/tests/bug54992.pem > ext/openssl/tests/bug54992.key
    ${openssl}/bin/openssl x509 -x509toreq -in ext/openssl/tests/bug54992.pem -out ext/openssl/tests/bug54992.csr -signkey ext/openssl/tests/bug54992.key
    ${openssl}/bin/openssl x509 -CA ext/openssl/tests/bug54992-ca.pem \
        -CAcreateserial \
        -CAkey ./ext/openssl/tests/bug54992-ca.key \
        -req \
        -in ext/openssl/tests/bug54992.csr \
        -sha256 \
        -days 400 \
        -out ./ext/openssl/tests/bug54992.pem
    ${coreutils}/bin/cat ext/openssl/tests/bug54992.key >> ext/openssl/tests/bug54992.pem
    ./sapi/cli/php -d phar.readonly=Off -r '$phar = new Phar("ext/openssl/tests/bug65538.phar"); $phar->addFile("ext/openssl/tests/bug54992.pem", "bug54992.pem"); $phar->addFile("ext/openssl/tests/bug54992-ca.pem", "bug54992-ca.pem");'
    ${gnused}/bin/sed -i ext/openssl/tests/openssl_peer_fingerprint_basic.phpt -e "s#b1d480a2f83594fa243d26378cf611f334d369e59558d87e3de1abe8f36cb997#$(openssl x509 -noout -fingerprint -sha256 -inform pem -in ext/openssl/tests/bug54992.pem | cut -d '=' -f 2 | tr -d ':' | tr 'A-F' 'a-f')#g"
  '';

  postCheck = ''
    ./sapi/cli/php -r 'if(PHP_ZTS) {echo "Unexpected thread safety detected (ZTS)\n"; exit(1);}'
  '';
}
