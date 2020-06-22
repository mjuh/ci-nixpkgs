self: super:

rec {
  inherit (super) callPackage symlinkJoin;

  lib = super.lib // (import ./lib { pkgs = self; });

  dockerTools = super.dockerTools // {
  buildLayeredImage = { topLayer ? null, minSize ? 10485760, contents, ... }@args:
    let
      popularityContestSized = callPackage ./pkgs/popularity-contest-sized {};
      referencesByPopularity = popularityContestSized topLayer minSize;
      dockerTools = super.dockerTools.override { inherit referencesByPopularity; }; 
    in
      dockerTools.buildLayeredImage ((removeAttrs args [ "minSize" "topLayer" ]) //
        { extraCommands = lib.optionalString (!isNull topLayer) ''
          mkdir -p nix/store
          for each in ${builtins.toString topLayer}
          do
            cp -r $each nix/store
          done
        '' + args.extraCommands or ""; });
   };

  pcre-lib-dev = symlinkJoin {
    name = "pcre-lib-dev";
    paths = [ super.pcre.out super.pcre.dev];
  };

  libxpm-lib-dev = symlinkJoin {
    name = "libxpm-lib-dev";
    paths = [ super.xorg.libXpm.out super.xorg.libXpm.dev];
  }; 

  libpng-lib-dev = symlinkJoin {
    name = "libpng-lib-dev";
    paths = [ super.libpng.out super.libpng.dev ];
  };

  libjpeg-lib-dev = symlinkJoin {
    name = "libjpeg-lib-dev";
    paths = [ super.libjpeg.out super.libjpeg.dev ];
  };

  libtiff-lib-dev = symlinkJoin {
    name = "libtiff-lib-dev";
    paths = [ super.libtiff.out super.libtiff.dev ];
  };

  freetype-all = symlinkJoin {
    name = "freetype-all";
    paths = [ super.freetype super.freetype.dev ];
  };

  lcms2-lib-dev = symlinkJoin {
    name = "lcms2-lib-dev";
    paths = [ super.lcms2.out super.lcms2.dev ];
  };

  zlib-all = symlinkJoin {
    name = "zlib-all";
    paths = [ super.zlib super.zlib.dev ];
  };

  withOpenSSL102 = rec {
    openssl = super.openssl_1_0_2;
    openssl-lib-dev = symlinkJoin {
      name = "openssl-1.0.2-lib-dev";
      paths = [ openssl.out openssl.dev ];
    };
    curl = super.curl.override {
      inherit openssl;
      libssh2 = super.libssh2.override { inherit openssl; };
    };
    curl-lib-dev = symlinkJoin {
      name = "curl-openssl-1.0.2-lib-dev";
      paths = [ curl.out curl.dev ];
    };
    uwimap = super.uwimap.override { inherit openssl; };
    postgresql = super.postgresql.override { inherit openssl; };
    mariadb-connector-c = mariadbConnectorC.override { inherit openssl; };
  };

  nss-certs = callPackage ./pkgs/nss-certs { cacert = super.cacert; };

  withMajordomoCacert = rec {
    cacert = callPackage ./pkgs/nss-certs { cacert = super.cacert; };
    parser3 = callPackage ./pkgs/parser { inherit cacert; };
    mjHttpErrorPages = callPackage ./pkgs/mj-http-error-pages { inherit cacert; };
  };

  zabbix-scripts = callPackage ./pkgs/zabbix-scripts { };
  zabbix-agentd-conf = callPackage ./pkgs/zabbix-agentd-conf { };
  parser3 = withMajordomoCacert.parser3;
  mjHttpErrorPages = withMajordomoCacert.mjHttpErrorPages;

  apacheHttpd = callPackage ./pkgs/apacheHttpd {};
  apacheHttpdmpmITK = callPackage ./pkgs/apacheHttpdmpmITK {};

  php44 = callPackage ./pkgs/php44 { postfix = sendmail; };
  php52 = callPackage ./pkgs/php52 { postfix = sendmail; };
  php53 = callPackage ./pkgs/php53 { postfix = sendmail; };
  php54 = callPackage ./pkgs/php54 { postfix = sendmail; };
  php55 = callPackage ./pkgs/php55 { postfix = sendmail; };
  php56 = callPackage ./pkgs/php56 { postfix = sendmail; };
  php70 = callPackage ./pkgs/php70 { postfix = sendmail; };
  php71 = callPackage ./pkgs/php71 { postfix = sendmail; };
  php72 = callPackage ./pkgs/php72 { postfix = sendmail; };
  php73 = callPackage ./pkgs/php73 { postfix = sendmail; };
  php74 = callPackage ./pkgs/php74 { postfix = sendmail; };

  buildPhp44Package = args: lib.buildPhpPackage ({ php = php44; } // args);
  buildPhp52Package = args: lib.buildPhpPackage ({ php = php52; } // args);
  buildPhp53Package = args: lib.buildPhpPackage ({ php = php53; } // args);
  buildPhp54Package = args: lib.buildPhpPackage ({ php = php54; } // args);
  buildPhp55Package = args: lib.buildPhpPackage ({ php = php55; } // args);
  buildPhp56Package = args: lib.buildPhpPackage ({ php = php56; } // args);
  buildPhp70Package = args: lib.buildPhpPackage ({ php = php70; } // args);
  buildPhp71Package = args: lib.buildPhpPackage ({ php = php71; } // args);
  buildPhp72Package = args: lib.buildPhpPackage ({ php = php72; } // args);
  buildPhp73Package = args: lib.buildPhpPackage ({ php = php73; } // args);
  buildPhp74Package = args: lib.buildPhpPackage ({ php = php74; } // args);

  buildPhp52PearPackage = args: lib.buildPhpPearPackage ({ php = php52; } // args);

  php52Packages = callPackage ./pkgs/php-packages/php52.nix {};
  php53Packages = callPackage ./pkgs/php-packages/php53.nix {};
  php54Packages = callPackage ./pkgs/php-packages/php54.nix {};
  php55Packages = callPackage ./pkgs/php-packages/php55.nix {};
  php56Packages = callPackage ./pkgs/php-packages/php56.nix {};
  php70Packages = callPackage ./pkgs/php-packages/php70.nix {};
  php71Packages = callPackage ./pkgs/php-packages/php71.nix {};
  php72Packages = callPackage ./pkgs/php-packages/php72.nix {};
  php73Packages = callPackage ./pkgs/php-packages/php73.nix {};
  php74Packages = callPackage ./pkgs/php-packages/php74.nix {};

  php73Personal = callPackage ./pkgs/php73/default.nix { personal = true; };
  php73PersonalFpm = callPackage ./pkgs/php73/default.nix { personal = true; enableFpm = true; };
  buildPhp73PersonalPackage = args: lib.buildPhpPackage ({ php = php73Personal; } // args);
  php73PersonalPackages = callPackage ./pkgs/php-packages/php73-personal.nix {};

  php74Personal = callPackage ./pkgs/php74/default.nix { personal = true; };
  php74PersonalFpm = callPackage ./pkgs/php74/default.nix { personal = true; enableFpm = true; };
  buildPhp74PersonalPackage = args: lib.buildPhpPackage ({ php = php74Personal; } // args);
  php74PersonalPackages = callPackage ./pkgs/php-packages/php74-personal.nix {};

  mperlInterpreters = callPackage ./pkgs/development/interpreters/perl {};
  inherit (mperlInterpreters) perl520;
  mjPerlPackages = (callPackage ./pkgs/mjperl5Packages { perl = perl520; perlPackages = perl520.pkgs; }).mjPerlPackages;
  mjperl5Packages = mjPerlPackages.perls;
  mjperl5lib = mjPerlPackages.mjPerlModules;

  luaInterpreters = super.luaInterpreters // rec {
    openrestyLuajit2 = callPackage ./pkgs/openresty-luajit2 { self = openrestyLuajit2; };
  };
  openrestyLuajit2 = luaInterpreters.openrestyLuajit2;
  openrestyPackages = openrestyLuajit2.pkgs;

  python37mj = with super; python37.override {
    packageOverrides = callPackage ./pkgs/python-packages/default.nix { python = python37; };
  };
  python38mj = with super; python38.override {
    packageOverrides = callPackage ./pkgs/python-packages/default.nix { python = python38; };
  };

  mkPythonCustomerPkgsSet = python: with super;
    rec {
      runPyPkgs = with python.pkgs; [ mysqlclient pandas lxml pillow ];
      buildPyPkgs = with python.pkgs; [ certifi cython ] ++ runPyPkgs;
      commonDeps = [
        freetype-all
        lcms2-lib-dev
        libjpeg-lib-dev
        libtiff-lib-dev
        ncurses.out
        zlib-all
      ];
      runDeps = [
        gcc-unwrapped.lib
        libffi.out
        libxml2.out
        libxslt.out
        mariadb.connector-c
        openssl.out
        postgresql.lib
      ];
      buildDeps = [
        libffi
        libxml2
        libxslt
        mariadb.connector-c.dev
        openssl
        postgresql
      ];
      runtime = commonDeps ++ runDeps ++ lib.resolvePythonPkgs runPyPkgs;
      buildtime = commonDeps ++ buildDeps ++ lib.resolvePythonPkgs buildPyPkgs;
  };

  python37mjCustomerPkgsSet = mkPythonCustomerPkgsSet python37mj;
  python38mjCustomerPkgsSet = mkPythonCustomerPkgsSet python38mj;

  clamchk = callPackage ./pkgs/clamchk {};
  elktail = callPackage ./pkgs/elktail {};
  imagemagick68 = callPackage ./pkgs/imagemagick68 {};
  inetutilsMinimal = callPackage ./pkgs/inetutils-minimal {};
  ioncube = callPackage ./pkgs/ioncube {};
  libjpeg8 = callPackage ./pkgs/libjpeg8 {};
  libjpeg130 = callPackage ./pkgs/libjpeg130 {};
  libjpegv6b = callPackage ./pkgs/libjpegv6b {};
  libpng12 = callPackage ./pkgs/libpng12 {};
  locale = callPackage ./pkgs/locale {};
  mariadbConnectorC = callPackage ./pkgs/mariadb-connector-c {};
  mcron = callPackage ./pkgs/mcron {};
  mysqlConnectorC = callPackage ./pkgs/mysql-connector-c {};
  nginx = callPackage ./pkgs/nginx {};
  nginxModules = callPackage ./pkgs/nginx-modules {};
  pcre831 = callPackage ./pkgs/pcre831 {};
  postfix = callPackage ./pkgs/postfix {};
  postfixDeprecated = callPackage ./pkgs/postfix-deprecated {};
  pure-ftpd = callPackage ./pkgs/pure-ftpd {};
  sendmail = callPackage ./pkgs/sendmail {};
  sh = callPackage ./pkgs/sh {};
  sockexec = callPackage ./pkgs/sockexec {};
  wordpress = callPackage ./pkgs/wordpress {};
  zendguard = callPackage ./pkgs/zendguard {};
  zendguard53 = zendguard.loader-php53;
  zendguard54 = zendguard.loader-php54;
  zendguard55 = zendguard.loader-php55;
  zendguard56 = zendguard.loader-php56;
  zendoptimizer = callPackage ./pkgs/zendoptimizer {};
  arcconf = callPackage ./pkgs/arcconf {};
  influxdb-subscription-cleaner = callPackage ./pkgs/influxdb-subscription-cleaner {};

  icu52 = callPackage (((import <nixpkgs> { }).fetchgit {
    url = "https://github.com/NixOS/nixpkgs.git";
    rev = "58be5387b8bc3de98fd95bbf3328a122abd2702f";
    sha256 = "0plk383da5rdzxwa5nw01qm83qfprl0kikbkmkdlvc4m6b19n4hn";
  }).outPath + "/pkgs/development/libraries/icu/default.nix") { };
  mj-phantomjs = callPackage ./pkgs/mj-phantomjs/default.nix {};

  automake113x = callPackage ./pkgs/automake113 { };
  cgrouptuner = callPackage ./pkgs/cgrouptuner { };
  libcgroup = callPackage ./pkgs/libcgroup { };

  phpinfoCompare = callPackage ./pkgs/phpinfo-compare {};
  maketestPhp = {php, image, rootfs, ...}@args:
    callPackage ./tests/apache.nix args;
  maketestPerl = {image, rootfs, ...}@args:
    callPackage ./tests/apache-perl.nix args;
  maketestNginx = {image, ...}@args:
    callPackage ./tests/nginx.nix args;
  maketestUwsgi = {image, ...}@args:
    callPackage ./tests/uwsgi.nix args;
  maketestSsh = {image, rootfs, ...}@args:
    callPackage ./tests/ssh.nix args;
  maketestPhpNginxPrivate = {php, image, rootfs, ...}@args:
    callPackage ./tests/nginx-private.nix args;
  dockerNodeTest = import ./tests/dockerNodeTest.nix;
  phpinfo = super.writeScript "phpinfo.php" "<?php phpinfo(); ?>";
  testDiffPy = import ./tests/scripts/deepdiff.nix;
  wordpressScript = import ./tests/scripts/wordpress.nix;
  wrkScript = import ./tests/scripts/wrk.nix;
  containerStructureTest = import ./tests/scripts/container-structure-test.nix;
  runCurl = url: output:
    builtins.concatStringsSep " " [
      "curl"
      "--connect-timeout"
      "180"
      "--fail"
      "--silent"
      "--output"
      output
      url
    ];
  runCurlGrep = url: string: builtins.concatStringsSep " " [
      "curl"
      "--connect-timeout"
      "180"
      "--silent"
      url
      "|"
      "grep"
      ("--max-count=" + "1")
      string
  ];
  bitrixServerTest = ./tests/bitrix_server_test.php;
  testPhpMariadbConnector = import ./tests/scripts/test-php-mariadb-connector.nix;
  testImages = import ./tests/images.nix;
  man-derivations-packages = packages: (builtins.map (p: super.lib.getOutput "man" p) packages) ++ packages;
}
