{ stdenv, lib, pcre2, uwimap, curl, zlib, libxml2, readline, sqlite,
  postgresql, freetype, libpng, libjpeg, gmp, gettext, libxslt,
  libmcrypt, bzip2, libsodium, html-tidy, libargon2, apacheHttpd,
  connectorc, pcre831, libjpeg130, libpng12, libjpegv6b }:

with import <nixpkgs> {};
with lib;

let
  generic =
    { version
    , sha256
    , extraPatches ? []
    , extraBuildInputs ? []
    , extraHardeningDisable ? []
    , extraConfigureFlags ? []
    }:

    stdenv.mkDerivation {

      inherit version;

      name = "php-${version}";

      src = []
            ++ optional ((versionAtLeast version "5.3") ||
                         (versionOlder version "5"))
              (fetchurl {
                url = [
                  "https://www.php.net/distributions/php-${version}.tar.bz2"
                  "https://museum.php.net/php5/php-${version}.tar.bz2"
                ];
                inherit sha256;
              });

      srcs = []
             ++ optional ((versionOlder version "5.3") &&
                          (versionAtLeast version "5.2"))
               [
                 ( fetchurl {
                   url = "https://museum.php.net/php5/php-${version}.tar.bz2";
                   inherit sha256;
                 })
                 ( fetchGit {
                   url = "https://gitlab.intr/pyhalov/php52-extra.git";
                   ref = "master";
                 })
               ];

      sourceRoot = []
                   ++ optional ((versionOlder version "5.3") &&
                                (versionAtLeast version "5.2"))
                     "php-${version}";

      enableParallelBuilding = true;

      patches = []
        ++ optional (versionAtLeast version "7.1") ./php71-fix-paths.patch
        ++ optional ((versionOlder version "7.0") &&
                     (versionAtLeast version "5.4")) ./php56-fix-apxs.patch
        ++ extraPatches;

      stripDebugList = "bin sbin lib modules";

      outputs = [ "out" ]
                ++ optional (versionAtLeast version "5.4") "dev";

      doCheck = false;

      checkTarget = "test";

      nativeBuildInputs =[
        pkgconfig
      ]
      ++ optional (versionOlder version "5.4") autoconf213
      ++ optional (versionAtLeast version "5.4") autoconf;

      buildInputs = [
        postfix automake curl apacheHttpd bison bzip2 flex freetype gettext
        gmp libmcrypt libmhash libxml2 xorg.libXpm.dev libxslt mariadb pam
        postgresql readline sqlite uwimap zlib libiconv t1lib libtidy kerberos
        openssl.dev glibcLocales sablotron
      ]
      ++ optional (versionOlder version "7.1") icu58
      ++ optional ((versionOlder version "7.3") &&
                   (versionAtLeast version "5.4")) pcre
      ++ optional (versionOlder version "5.4") pcre831
      ++ optional (versionAtLeast version "7.3") pcre2
      ++ optional (versionAtLeast version "7.1") icu
      ++ optional (versionAtLeast version "7.1") icu.dev
      ++ optional ((versionOlder version "5.3") &&
                   (versionAtLeast version "5.2"))
        libjpeg130
      ++ optional (versionOlder version "5") libjpegv6b
      ++ optional (versionAtLeast version "5.3") libjpeg
      ++ optional (versionAtLeast version "5.3") libpng
      ++ optional (versionOlder version "5.3") libpng12
      ++ optional (versionOlder version "5.3") libmhash
      ++ optional (versionOlder version "7.0") connectorc
      ++ optional (versionAtLeast version "5.3") libsodium
      ++ optional (versionAtLeast version "5.3") libzip
      ++ optional ((versionAtLeast version "5.3") ||
                   (versionOlder version "5"))
        expat
      ++ extraBuildInputs;

      CXXFLAGS = "-std=c++11";

      configureFlags = [
        "--disable-cgi"
        "--disable-debug"
        "--disable-maintainer-zts"
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
        "--with-zlib=${zlib.dev}"
        "--with-xslt-sablot=${sablotron}"
        "--with-config-file-scan-dir=/run/php.d"
      ]
      ++ optional (versionAtLeast version "5.3") "--disable-fpm"
      ++ optional (versionAtLeast version "5.3")
        "--with-sodium=${libsodium.dev}"
      ++ optional (versionAtLeast version "5.3")
        "--with-password-argon2=${libargon2}"
      ++ optional (versionAtLeast version "5.3") "--with-libzip"
      ++ optional (versionAtLeast version "5.3") "--enable-timezonedb"
      ++ optional (versionAtLeast version "5.3") "--enable-opcache"
      ++ optional (versionAtLeast version "5.3") "--disable-pthreads"
      ++ optional (versionAtLeast version "5.3") "--disable-phpdbg"
      ++ optional (versionAtLeast version "5.3") "--disable-memcached-sasl"

      ++ optional (versionAtLeast version "7.0") "--with-gettext=${gettext}"
      ++ optional (versionOlder version "7.0") "--with-gettext=${glibc.dev}"

      ++ optional (versionAtLeast version "7.0") "--enable-intl"

      ++ optional (versionAtLeast version "7.0") "--with-pdo-mysql=mysqlnd"
      ++ optional (versionOlder version "7.0")
        "--with-pdo-mysql=${connectorc}"

      ++ optional (versionAtLeast version "7.0") "--with-mysql=mysqlnd"
      ++ optional (versionOlder version "7.0") "--with-mysql=${connectorc}"

      ++ optional (versionAtLeast version "7.0") "--with-mysqli=mysqlnd"
      ++ optional (versionOlder version "7.0")
        "--with-mysqli=${connectorc}/bin/mysql_config"
      ++ optional (versionAtLeast version "7.3")
        "--with-pcre-regex=${pcre2.dev} PCRE_LIBDIR=${pcre2}"
      ++ optional ((versionOlder version "7.3") &&
                   (versionAtLeast version "5.4"))
        "--with-pcre-regex=${pcre.dev} PCRE_LIBDIR=${pcre}"
      ++ optional ((versionOlder version "7.0") &&
                   (versionAtLeast version "5.4"))
        "--with-pcre-regex=${pcre.dev} PCRE_LIBDIR=${pcre831}"

      ++ optional (versionAtLeast version "5.3")
        "--with-jpeg-dir=${libjpeg.dev}"
      ++ optional ((versionOlder version "5.3") &&
                   (versionAtLeast version "5.2"))
        "--with-jpeg-dir=${libjpeg130}"
      ++ optional (versionOlder version "5") "--with-jpeg-dir=${libjpegv6b}"

      ++ optional (versionAtLeast version "7.0") "--without-pthreads"

      ++ optional (versionAtLeast version "5.3")
        "--with-png-dir=${libpng.dev}"
      ++ optional (versionOlder version "5.3") "--with-png-dir=${libpng12}"

      ++ optional (versionOlder version "5.3") "--with-mhash=${libmhash}"

      ++ optional (versionAtLeast version "5.3") "--disable-posix-threads"

      ++ optional (versionAtLeast version "5.2") "--with-xslt"
      ++ optional (versionAtLeast version "5.2")
        "--with-libxml-dir=${libxml2.dev}"
      ++ optional (versionAtLeast version "5.2") "--enable-libxml"
      ++ optional (versionAtLeast version "5.2") "--with-xmlrpc"

      ++ extraConfigureFlags;

      hardeningDisable = [ "bindnow" ] ++ extraHardeningDisable;

      preConfigure = []
                     ++ optional ((versionAtLeast version "4") &&
                                  (versionOlder version "5"))
                       ''
        find -type f -exec sed -i 's/-DZTS//g' {} +
        ''

        ++ optional (versionAtLeast version "5.2")
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

      ++ optional (versionOlder version "5.3") ''
          substituteInPlace ext/gmp/gmp.c --replace '__GMP_BITS_PER_MP_LIMB' 'GMP_LIMB_BITS'
        ''

      ++ optional ((versionOlder version "5.3") &&
                   (versionAtLeast version "5.2"))
        ''
      cp -vr ../source/* ./
      ''

      ++ optional ((versionOlder version "7.1") &&
                   (versionAtLeast version "5.2"))
        ''
        substituteInPlace ext/tidy/tidy.c \
            --replace buffio.h tidybuffio.h
        ''

      ++ optional (versionOlder version "5.3") ''
         substituteInPlace configure \
           --replace enable_maintainer_zts=yes enable_maintainer_zts=no
         ''

      ++ [''
        [[ -z "$libxml2" ]] || addToSearchPath PATH $libxml2/bin

        export EXTENSION_DIR=$out/lib/php/extensions

        configureFlags+=(--with-config-file-path=$out/etc \
          --includedir=$dev/include)

        ./buildconf --force
      ''];

      postFixup = []
      ++ optional (versionAtLeast version "5.4") ''
             mkdir -p $dev/bin $dev/share/man/man1
             mv $out/bin/phpize $out/bin/php-config $dev/bin/
             mv $out/share/man/man1/phpize.1.gz \
             $out/share/man/man1/php-config.1.gz \
             $dev/share/man/man1/
      '';

      postConfigure = []
                    ++ optional (versionAtLeast version "4")
                     ''
                     substituteInPlace configure --replace enable_experimental_zts=yes enable_experimental_zts=no
                     ''

                    ++ optional (versionOlder version "7.0")
                      ''
                      sed -i ./main/build-defs.h -e '/PHP_INSTALL_IT/d'
                      '';
    };

in {
  php4 = generic {
    version = "4.4.9";
    sha256 = "1hjn2sdm8sn8xsd1y5jlarx3ddimdvm56p1fxaj0ydm3dgah5i9a";
    extraPatches = [
      ./php4-apache24.patch ./php4-openssl.patch ./php4-domxml.patch
      ./php4-pcre.patch ./php4-apxs.patch ./php4-configure.patch
    ];
    extraHardeningDisable = [
      "fortify" "stackprotector" "pie" "pic" "strictoverflow" "format"
      "relro"
    ];
    extraConfigureFlags = [
      "--with-expat-dir=${expat}" "--with-kerberos"
      "--with-dom=${libxml2.dev}" "--with-dom-xslt=${libxslt.dev}"
      "--enable-force-cgi-redirect" "--enable-local-infile"
      "--enable-mbstring=ru" "--enable-memory-limit" "--enable-wddx"
      "--enable-xslt" "--with-dbase" "--with-iconv" "--with-ttf" "--with-xslt"
    ];
  };
  php52 = generic {
    version = "5.2.17";
    sha256 = "e81beb13ec242ab700e56f366e9da52fd6cf18961d155b23304ca870e53f116c";
    extraPatches = [
      ./php52-backport_crypt_from_php53.patch ./php52-configure.patch
      ./php52-zts.patch ./php52-fix-pcre-php52.patch
      ./php52-debian_patches_disable_SSLv2_for_openssl_1_0_0.patch.patch
      ./php52-fix-exif-buffer-overflow.patch
      ./php52-libxml2-2-9_adapt_documenttype.patch
      ./php52-libxml2-2-9_adapt_node.patch
      ./php52-libxml2-2-9_adapt_simplexml.patch
      ./php52-mj_engineers_apache2_4_abi_fix.patch
      ./php52-fix-mysqli-buffer-overflow.patch
      ./php52-add-configure-flags.patch
    ];
  };
  php53 = generic {
    version = "5.3.29";
    sha256 = "1480pfp4391byqzmvdmbxkdkqwdzhdylj63sfzrcgadjf9lwzqf4";
    extraPatches = [
      ./php53-fix-exif-buffer-overflow.patch
      ./php53-fix-mysqli-buffer-overflow.patch ./php53-fix-configure.patch
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
      ./php7-apxs.patch ./php70-fix-paths.patch
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
