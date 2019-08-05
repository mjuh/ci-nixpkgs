{ stdenv, lib, pcre2, uwimap, curl, zlib, libxml2, readline, sqlite,
  postgresql, freetype, libpng, libjpeg, gmp, gettext, libxslt,
  libmcrypt, bzip2, libsodium, html-tidy, libargon2, apacheHttpd,
  connectorc, pcre831 }:

with import <nixpkgs> {};
with lib;

let
  generic =
    { version
    , sha256
    , extraPatches ? []
    , extraBuildInputs ? []
    }:

    stdenv.mkDerivation {

      inherit version;

      name = "php-${version}";

      src = fetchurl {
        url = ["https://www.php.net/distributions/php-${version}.tar.bz2"
               "https://museum.php.net/php5/php-${version}.tar.bz2"];
        inherit sha256;
      };

      enableParallelBuilding = true;

      meta = with stdenv.lib; {
        description = "An HTML-embedded scripting language";
        homepage = https://www.php.net/;
        license = licenses.php301;
        platforms = platforms.all;
        outputsToInstall = [ "out" "dev" ];
      };

      patches = []
        ++ optional (versionAtLeast version "7.1") ./php71-fix-paths.patch
        ++ optional ((versionOlder version "7.0") && (versionAtLeast version "5.4")) ./php56-fix-apxs.patch
        ++ extraPatches;

      stripDebugList = "bin sbin lib modules";

      outputs = [ "out" "dev" ];

      doCheck = false;

      checkTarget = "test";

      nativeBuildInputs =[
        pkgconfig
      ]
      ++ optional (versionOlder version "5.4") autoconf213
      ++ optional (versionAtLeast version "5.4") autoconf;

      buildInputs = [
        postfix
        automake
        curl
        apacheHttpd
        bison
        bzip2
        flex
        freetype
        gettext
        gmp
        libzip
        libjpeg
        libmcrypt
        libmhash
        libpng
        libxml2
        libsodium
        xorg.libXpm.dev
        libxslt
        mariadb
        pam
        postgresql
        readline
        sqlite
        uwimap
        zlib
        libiconv
        t1lib
        libtidy
        kerberos
        openssl.dev
        glibcLocales
      ]
      ++ optional (versionOlder version "7.1") icu58
      ++ optional ((versionOlder version "7.3") && (versionAtLeast version "5.4")) pcre
      ++ optional (versionOlder version "5.4") pcre831
      ++ optional (versionAtLeast version "7.3") pcre2
      ++ optional (versionAtLeast version "7.1") icu
      ++ optional (versionAtLeast version "7.1") icu.dev
      ++ extraBuildInputs;

      CXXFLAGS = "-std=c++11";

      configureFlags = [
        "--disable-cgi"
        "--disable-debug"
        "--disable-fpm"
        "--disable-maintainer-zts"
        "--disable-memcached-sasl"
        "--disable-phpdbg"
        "--disable-pthreads"
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
        "--enable-opcache"
        "--enable-pdo"
        "--enable-soap"
        "--enable-sockets"
        "--enable-sysvsem"
        "--enable-sysvshm"
        "--enable-timezonedb"
        "--enable-zip"
        "--with-apxs2=${apacheHttpd.dev}/bin/apxs"
        "--with-bz2=${bzip2.dev}"
        "--with-config-file-scan-dir=/etc/php.d"
        "--with-curl=${curl.dev}"
        "--with-curlwrappers"
        "--with-freetype-dir=${freetype.dev}"
        "--with-gd"
        "--with-gmp=${gmp.dev}"
        "--with-imap-ssl"
        "--with-imap=${uwimap}"
        "--with-jpeg-dir=${libjpeg.dev}"
        "--with-libxml-dir=${libxml2.dev}"
        "--with-libzip"
        "--with-mcrypt=${libmcrypt}"
        "--with-mhash"
        "--with-openssl"
        "--with-password-argon2=${libargon2}"
        "--with-pdo-pgsql=${postgresql}"
        "--with-pdo-sqlite=${sqlite.dev}"
        "--with-pgsql=${postgresql}"
        "--with-png-dir=${libpng.dev}"
        "--with-readline=${readline.dev}"
        "--with-sodium=${libsodium.dev}"
        "--with-tidy=${html-tidy}"
        "--with-xmlrpc"
        "--with-xsl=${libxslt.dev}"
        "--with-zlib=${zlib.dev}"
      ]
      ++ optional (versionAtLeast version "7.0") "--with-gettext=${gettext}"
      ++ optional (versionOlder version "7.0") "--with-gettext=${glibc.dev}"

      ++ optional (versionAtLeast version "7.0") "--enable-intl"

      ++ optional (versionAtLeast version "7.0") "--with-pdo-mysql=mysqlnd"
      ++ optional (versionOlder version "7.0") "--with-pdo-mysql=${connectorc}"

      ++ optional (versionAtLeast version "7.0") "--with-mysql=mysqlnd"
      ++ optional (versionOlder version "7.0") "--with-mysql=${connectorc}"

      ++ optional (versionAtLeast version "7.0") "--with-mysqli=mysqlnd"
      ++ optional (versionOlder version "7.0") "--with-mysqli=${connectorc}/bin/mysql_config"
      ++ optional (versionAtLeast version "7.3")
        "--with-pcre-regex=${pcre2.dev} PCRE_LIBDIR=${pcre2}"
      ++ optional ((versionOlder version "7.3") && (versionAtLeast version "5.4"))
        "--with-pcre-regex=${pcre.dev} PCRE_LIBDIR=${pcre}"
      ++ optional ((versionOlder version "7.0") && (versionAtLeast version "5.4"))
        "--with-pcre-regex=${pcre.dev} PCRE_LIBDIR=${pcre831}"

      ++ optional (versionAtLeast version "7.0") "--without-pthreads";
      hardeningDisable = [ "bindnow" ];

      preConfigure = [''
        # Don't record the configure flags since this causes unnecessary
        # runtime dependencies
        for i in main/build-defs.h.in scripts/php-config.in; do
          substituteInPlace $i \
            --replace '@CONFIGURE_COMMAND@' '(omitted)' \
            --replace '@CONFIGURE_OPTIONS@' "" \
            --replace '@PHP_LDFLAGS@' ""
        done
        '']

      ++ optional (versionOlder version "7.1") ''
        substituteInPlace ext/tidy/tidy.c \
            --replace buffio.h tidybuffio.h
        ''

      ++ [''
        [[ -z "$libxml2" ]] || addToSearchPath PATH $libxml2/bin

        export EXTENSION_DIR=$out/lib/php/extensions

        configureFlags+=(--with-config-file-path=$out/etc \
          --includedir=$dev/include)

        ./buildconf --force
      ''];

      postFixup = ''
             mkdir -p $dev/bin $dev/share/man/man1
             mv $out/bin/phpize $out/bin/php-config $dev/bin/
             mv $out/share/man/man1/phpize.1.gz \
             $out/share/man/man1/php-config.1.gz \
             $dev/share/man/man1/
      '';

      postConfigure = []
                    ++ optional (versionOlder version "7.0")
                      ''
                      sed -i ./main/build-defs.h -e '/PHP_INSTALL_IT/d'
                      '';
    };

in {
  php4 = generic {
    version = "5.4.45";
    sha256 = "4e0d28b1554c95cfaea6fa2b64aac85433f158ce72bb571bcd5574f98f4c6582";
  };
  php52 = generic {
    version = "5.2.17";
    sha256 = "e81beb13ec242ab700e56f366e9da52fd6cf18961d155b23304ca870e53f116c";
  };
  php53 = generic {
    version = "5.3.29";
    sha256 = "1480pfp4391byqzmvdmbxkdkqwdzhdylj63sfzrcgadjf9lwzqf4";
    extraPatches = [
      ./php53-fix-exif-buffer-overflow.patch
      ./php53-fix-mysqli-buffer-overflow.patch
      ./php53-fix-configure.patch
    ];
  };
  php54 = generic {
    version = "5.4.45";
    sha256 = "4e0d28b1554c95cfaea6fa2b64aac85433f158ce72bb571bcd5574f98f4c6582";
    extraPatches = [
      ./php70-fix-paths.patch
    ];
  };
  php55 = generic {
    version = "5.5.38";
    sha256 = "0f1y76whg6yx9a18mh97f8yq8lb64ri1f0zfr9la9374nbmq2g27";
  };
  php56 = generic {
    version = "5.6.40";
    sha256 = "005s7w167dypl41wlrf51niryvwy1hfv53zxyyr3lm938v9jbl7z";
  };
  php70 = generic {
    version = "7.0.33";
    sha256 = "4933ea74298a1ba046b0246fe3771415c84dfb878396201b56cb5333abe86f07";
    extraPatches = [
      ./php7-apxs.patch
      ./php70-fix-paths.patch
    ];
 };
  php71 = generic {
    version = "7.1.30";
    sha256 = "664850774fca19d2710b9aa35e9ae91214babbde9cd8d27fd3479cc97171ecb3";
  };
  php72 = generic {
    version = "7.2.20";
    sha256 = "9fb829e54e54c483ae8892d1db0f7d79115cc698f2f3591a8a5e58d9410dca84";
  };
  php73 = generic {
    version = "7.3.7";
    sha256 = "065z2q6imjxlbh6w1r7565ygqhigfbzcz70iaic74hj626kqyq63";
  };
}
