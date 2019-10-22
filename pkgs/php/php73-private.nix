{ lib, stdenv, apacheHttpd, autoconf, autoconf213, automake, bison, bzip2
, callPackage, connectorc, curl, expat, fetchurl, flex, freetype, gettext, glibc
, glibcLocales, gmp, html-tidy, icu, icu58, kerberos, libargon2, libiconv
, libjpeg, libjpeg130, libjpegv6b, libmcrypt, libmhash, libpng, libpng12
, libsodium, libtidy, libxml2, libxslt, libwebp, libzip, mariadb, openssl, pam
, pcre, pcre2, pcre831, pkgconfig, postfix, postgresql, readline, sablotron
, sqlite, t1lib, uwimap, xorg, zlib }:
with lib;
stdenv.mkDerivation {
  name = "php73-${version}";
  version = "7.3.9";
  src = fetchurl {
    url = "http://www.php.net/distributions/php-7.3.9.tar.bz2";
    sha256 = "1i33v50rbqrfwjwch1d46mbpwbxrg1xfycs9mjl7xsy9m04rg753";
  };
  enableParallelBuilding = true;
  stripDebugList = "bin sbin lib modules";
  checkTarget = "test";
  doCheck = true;
  postConfigure = [
    ''
      sed -i ./main/build-defs.h -e '/PHP_INSTALL_IT/d'
      sed -i ./main/build-defs.h -e '/CONFIGURE_COMMAND/d'
    ''
  ];
  preConfigure = [
    ''
      # Don't record the configure flags since this causes unnecessary
      # runtime dependencies
      for i in main/build-defs.h.in scripts/php-config.in; do
        substituteInPlace $i \
          --replace '@CONFIGURE_COMMAND@' '(omitted)' \
          --replace '@CONFIGURE_OPTIONS@' "" \
          --replace '@PHP_LDFLAGS@' ""
      done
    ''
    ''
      [[ -z "$libxml2" ]] || addToSearchPath PATH $libxml2/bin

      export EXTENSION_DIR=$out/lib/php/extensions

      configureFlags+=(--with-config-file-path=$out/etc \
        --includedir=$dev/include)

      ./buildconf --force
    ''
  ];
  preCheck = [
    ''
      for file in  ext/posix/tests/posix_getgrgid.phpt ext/sockets/tests/bug63000.phpt ext/sockets/tests/socket_shutdown.phpt ext/sockets/tests/socket_send.phpt ext/sockets/tests/mcast_ipv4_recv.phpt ext/standard/tests/general_functions/getservbyname_basic.phpt ext/standard/tests/general_functions/getservbyport_basic.phpt ext/standard/tests/general_functions/getservbyport_variation1.phpt ext/standard/tests/network/getprotobyname_basic.phpt ext/standard/tests/network/getprotobynumber_basic.phpt ext/standard/tests/strings/setlocale_basic1.phpt ext/standard/tests/strings/setlocale_basic2.phpt ext/standard/tests/strings/setlocale_basic3.phpt ext/standard/tests/strings/setlocale_variation1.phpt ext/gd/tests/bug39780_extern.phpt ext/gd/tests/libgd00086_extern.phpt ext/gd/tests/bug45799.phpt ext/gd/tests/bug66356.phpt ext/gd/tests/bug72339.phpt ext/gd/tests/bug72482.phpt ext/gd/tests/bug72482_2.phpt ext/gd/tests/bug73213.phpt ext/gd/tests/createfromwbmp2_extern.phpt ext/gd/tests/bug65148.phpt ext/gd/tests/bug77198_auto.phpt ext/gd/tests/bug77198_threshold.phpt ext/gd/tests/bug77200.phpt ext/gd/tests/bug77269.phpt ext/gd/tests/xpm2gd.phpt ext/gd/tests/xpm2jpg.phpt ext/gd/tests/xpm2png.phpt ext/gd/tests/bug77479.phpt ext/gd/tests/bug77272.phpt ext/gd/tests/bug77973.phpt ext/iconv/tests/bug52211.phpt ext/iconv/tests/bug60494.phpt ext/iconv/tests/iconv_mime_decode_variation3.phpt ext/iconv/tests/iconv_strlen_error2.phpt ext/iconv/tests/iconv_strlen_variation2.phpt ext/iconv/tests/iconv_substr_error2.phpt ext/iconv/tests/iconv_strpos_error2.phpt ext/iconv/tests/iconv_strrpos_error2.phpt ext/iconv/tests/iconv_strpos_variation4.phpt ext/iconv/tests/iconv_strrpos_variation3.phpt ext/iconv/tests/bug76249.phpt ext/curl/tests/bug61948.phpt ext/curl/tests/curl_basic_009.phpt ext/standard/tests/file/bug41655_1.phpt ext/standard/tests/file/glob_variation5.phpt ext/standard/tests/streams/proc_open_bug64438.phpt ext/gd/tests/bug43073.phpt ext/gd/tests/bug48732-mb.phpt ext/gd/tests/bug48732.phpt ext/gd/tests/bug48801-mb.phpt ext/gd/tests/bug48801.phpt ext/gd/tests/bug53504.phpt ext/gd/tests/bug73272.phpt ext/iconv/tests/bug48147.phpt ext/iconv/tests/bug51250.phpt ext/iconv/tests/iconv003.phpt ext/iconv/tests/iconv_mime_encode.phpt ext/standard/tests/file/bug43008.phpt ext/pdo_sqlite/tests/bug_42589.phpt ext/mbstring/tests/mb_ereg_variation3.phpt ext/mbstring/tests/mb_ereg_replace_variation1.phpt ext/mbstring/tests/bug72994.phpt ext/mbstring/tests/bug77367.phpt ext/mbstring/tests/bug77370.phpt ext/mbstring/tests/bug77371.phpt ext/mbstring/tests/bug77381.phpt ext/mbstring/tests/mbregex_stack_limit.phpt ext/mbstring/tests/mbregex_stack_limit2.phpt ext/ldap/tests/ldap_set_option_error.phpt ext/ldap/tests/bug76248.phpt ext/pcre/tests/bug76909.phpt ext/curl/tests/bug64267.phpt ext/curl/tests/bug76675.phpt ext/date/tests/bug52480.phpt ext/date/tests/DateTime_add-fall-type2-type3.phpt ext/date/tests/DateTime_add-fall-type3-type2.phpt ext/date/tests/DateTime_add-fall-type3-type3.phpt ext/date/tests/DateTime_add-spring-type2-type3.phpt ext/date/tests/DateTime_add-spring-type3-type2.phpt ext/date/tests/DateTime_add-spring-type3-type3.phpt ext/date/tests/DateTime_diff-fall-type2-type3.phpt ext/date/tests/DateTime_diff-fall-type3-type2.phpt ext/date/tests/DateTime_diff-fall-type3-type3.phpt ext/date/tests/DateTime_diff-spring-type2-type3.phpt ext/date/tests/DateTime_diff-spring-type3-type2.phpt ext/date/tests/DateTime_diff-spring-type3-type3.phpt ext/date/tests/DateTime_sub-fall-type2-type3.phpt ext/date/tests/DateTime_sub-fall-type3-type2.phpt ext/date/tests/DateTime_sub-fall-type3-type3.phpt ext/date/tests/DateTime_sub-spring-type2-type3.phpt ext/date/tests/DateTime_sub-spring-type3-type2.phpt ext/date/tests/DateTime_sub-spring-type3-type3.phpt ext/date/tests/rfc-datetime_and_daylight_saving_time-type3-bd2.phpt ext/date/tests/rfc-datetime_and_daylight_saving_time-type3-fs.phpt ext/filter/tests/bug49184.phpt ext/filter/tests/bug67167.02.phpt ext/iconv/tests/bug48147.phpt ext/iconv/tests/bug51250.phpt ext/iconv/tests/bug52211.phpt ext/iconv/tests/bug60494.phpt ext/iconv/tests/bug76249.phpt ext/iconv/tests/iconv_mime_decode_variation3.phpt ext/iconv/tests/iconv_mime_encode.phpt ext/iconv/tests/iconv_strlen_error2.phpt ext/iconv/tests/iconv_strlen_variation2.phpt ext/iconv/tests/iconv_strpos_error2.phpt ext/iconv/tests/iconv_strpos_variation4.phpt ext/iconv/tests/iconv_strrpos_error2.phpt ext/iconv/tests/iconv_strrpos_variation3.phpt ext/iconv/tests/iconv_substr_error2.phpt ext/mbstring/tests/bug52861.phpt ext/mbstring/tests/mb_send_mail01.phpt ext/mbstring/tests/mb_send_mail02.phpt ext/mbstring/tests/mb_send_mail03.phpt ext/mbstring/tests/mb_send_mail04.phpt ext/mbstring/tests/mb_send_mail05.phpt ext/mbstring/tests/mb_send_mail06.phpt ext/mbstring/tests/mb_send_mail07.phpt ext/openssl/tests/bug65538_002.phpt ext/pdo_sqlite/tests/bug_42589.phpt ext/pdo_sqlite/tests/pdo_022.phpt ext/phar/tests/bug69958.phpt ext/posix/tests/posix_errno_variation1.phpt ext/posix/tests/posix_errno_variation2.phpt ext/posix/tests/posix_kill_basic.phpt ext/session/tests/bug71162.phpt ext/session/tests/bug73529.phpt ext/soap/tests/bug71610.phpt ext/soap/tests/bugs/bug76348.phpt ext/sockets/tests/mcast_ipv4_recv.phpt ext/sockets/tests/socket_bind.phpt ext/sockets/tests/socket_send.phpt ext/sockets/tests/socket_shutdown.phpt ext/standard/tests/file/006_variation2.phpt ext/standard/tests/file/bug41655_1.phpt ext/standard/tests/file/bug43008.phpt ext/standard/tests/file/chmod_basic.phpt ext/standard/tests/file/chmod_variation4.phpt ext/standard/tests/general_functions/getservbyname_basic.phpt ext/standard/tests/general_functions/getservbyport_basic.phpt ext/standard/tests/general_functions/getservbyport_variation1.phpt ext/standard/tests/general_functions/proc_nice_basic.phpt ext/standard/tests/network/gethostbyname_error004.phpt ext/standard/tests/network/getmxrr.phpt ext/standard/tests/network/getprotobyname_basic.phpt ext/standard/tests/network/getprotobynumber_basic.phpt ext/standard/tests/serialize/bug70219.phpt ext/standard/tests/streams/bug60602.phpt ext/standard/tests/streams/bug74090.phpt ext/standard/tests/streams/stream_context_tcp_nodelay_fopen.phpt ext/standard/tests/streams/stream_context_tcp_nodelay.phpt ext/tidy/tests/020.phpt sapi/cli/tests/cli_process_title_unix.phpt tests/output/stream_isatty_err.phpt tests/output/stream_isatty_in-err.phpt tests/output/stream_isatty_in-out.phpt tests/output/stream_isatty_out-err.phpt tests/output/stream_isatty_out.phpt tests/security/open_basedir_linkinfo.phpt Zend/tests/access_modifiers_008.phpt Zend/tests/access_modifiers_009.phpt Zend/tests/bug48770_2.phpt Zend/tests/bug48770_3.phpt Zend/tests/bug48770.phpt Zend/tests/method_static_var.phpt ext/curl/tests/curl_multi_info_read.phpt; do
        rm $file || true
      done
    ''
    ''
      for file in  ext/standard/tests/general_functions/phpinfo.phpt ext/openssl/tests/openssl_encrypt_ccm.phpt ext/openssl/tests/stream_server_reneg_limit.phpt; do
        rm $file || true
      done
    ''
    ''
      for file in  ext/standard/tests/file/006_error.phpt sapi/cli/tests/upload_2G.phpt; do
        rm $file || true
      done
    ''
    ''
      for file in  ext/tidy/tests/030.phpt ext/standard/tests/file/006_error.phpt ext/pcre/tests/bug78338.phpt; do
        rm $file || true
      done
    ''
  ];
  patches = [
    ./php71-fix-paths.patch

  ];
  hardeningDisable = [ "bindnow" ];
  CXXFLAGS = "-std=c++11";
  buildInputs = [
    apacheHttpd
    automake
    bison
    bzip2
    curl
    flex
    freetype
    gettext
    glibcLocales
    gmp
    kerberos
    libiconv
    libmcrypt
    libmhash
    html-tidy
    libxml2
    libxslt
    mariadb
    openssl
    pam
    postfix
    postgresql
    readline
    sablotron
    sqlite
    t1lib
    uwimap
    xorg.libXpm
    zlib
    libpng
    libsodium
    libzip
    libjpeg
    icu
    icu
    pcre2
    expat
  ];
  nativeBuildInputs = [ pkgconfig autoconf ];
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
    "--with-curl=${curl.dev}"
    "--with-curlwrappers"
    "--with-freetype-dir=${freetype.dev}"
    "--with-gd"
    "--with-gmp=${gmp.dev}"
    "--with-imap-ssl"
    "--with-imap=${uwimap}"
    "--with-mcrypt=${libmcrypt}"
    "--with-mhash"
    "--with-openssl"
    "--with-pdo-pgsql=${postgresql}"
    "--with-pdo-sqlite=${sqlite.dev}"
    "--with-pgsql=${postgresql}"
    "--with-readline=${readline.dev}"
    "--with-tidy=${html-tidy}"
    "--with-xsl=${libxslt.dev}"
    "--with-xslt-sablot=${sablotron}"
    "--with-zlib=${zlib.dev}"
    "--enable-libxml"
    "--with-libxml-dir=${libxml2.dev}"
    "--with-xmlrpc"
    "--with-xslt"
    "--enable-fpm"
    "--disable-memcached-sasl"
    "--disable-phpdbg"
    "--enable-opcache"
    "--enable-timezonedb"
    "--with-png-dir=${libpng.dev}"
    "--with-libzip"
    "--with-password-argon2=${libargon2}"
    "--with-sodium=${libsodium.dev}"
    "--with-mysql=mysqlnd"
    "--with-mysqli=mysqlnd"
    "--with-pdo-mysql=mysqlnd"
    "--with-config-file-scan-dir=/etc/php73.d/"
    "--enable-intl"
    "--with-gettext=${gettext}"
    "--with-webp-dir=${libwebp}"
    "--without-pthreads"
    "--with-pcre-regex=${pcre2.dev}"
    "PCRE_LIBDIR=${pcre2.dev}"
    "--with-jpeg-dir=${libjpeg.dev}"
  ];
}
