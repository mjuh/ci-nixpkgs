self: super:

rec {
  inherit (super) callPackage symlinkJoin;

  lib = super.lib // (import ./lib.nix { pkgs = self; });

  dockerTools = super.dockerTools // {
  buildLayeredImage = { topLayer ? null, minSize ? 10485760, contents, ... }@args:
    let
      popularityContestSized = callPackage ./pkgs/popularity-contest-sized {};
      referencesByPopularity = popularityContestSized topLayer minSize;
      dockerTools = super.dockerTools.override { inherit referencesByPopularity; }; 
    in
      dockerTools.buildLayeredImage ((lib.dropAttrs [ "minSize" "topLayer" ] args) //
        { extraCommands = lib.optionalString (!isNull topLayer) ''
          mkdir -p nix/store
          for each in ${builtins.toString topLayer}
          do
            cp -r $each nix/store
          done
        '' + args.extraCommands; });
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

  php73Private = callPackage ./pkgs/php/php73-private.nix {};
  buildPhp73PrivatePackage = args: lib.buildPhpPackage ({ php = php73Private; } // args);
  php73PrivatePackages = callPackage ./pkgs/php-packages/php73-private.nix {};

  mperlInterpreters = callPackage ./pkgs/development/interpreters/perl {};
  inherit (mperlInterpreters) perl520;
  mjperl5Packages = (callPackage ./pkgs/mjperl5Packages { perl = perl520; perlPackages = perl520.pkgs; }).mjPerlPackages.perls;
  mjperl5lib = (callPackage ./pkgs/mjperl5Packages { perl = perl520; perlPackages = perl520.pkgs; }).mjPerlPackages.mjPerlModules;

  clamchk = callPackage ./pkgs/clamchk {};
  deepdiff = callPackage ./pkgs/deepdiff {};
  elktail = callPackage ./pkgs/elktail {};
  imagemagick68 = callPackage ./pkgs/imagemagick68 {};
  inetutilsMinimal = callPackage ./pkgs/inetutils-minimal {};
  ioncube = callPackage ./pkgs/ioncube {};
  libjpeg130 = callPackage ./pkgs/libjpeg130 {};
  libjpegv6b = callPackage ./pkgs/libjpegv6b {};
  libpng12 = callPackage ./pkgs/libpng12 {};
  locale = callPackage ./pkgs/locale {};
  luajitPackages = super.luajitPackages.override { lua = openrestyLuajit2; }
    // (callPackage ./pkgs/luajit-packages { lua = openrestyLuajit2; });
  mariadbConnectorC = callPackage ./pkgs/mariadb-connector-c {};
  mcron = callPackage ./pkgs/mcron {};
  mjHttpErrorPages = callPackage ./pkgs/mj-http-error-pages {};
  mysqlConnectorC = callPackage ./pkgs/mysql-connector-c {};
  nginx = callPackage ./pkgs/nginx {};
  nginxModules = callPackage ./pkgs/nginx-modules {};
  nss-certs = callPackage ./pkgs/nss-certs {};
  openrestyLuajit2 = callPackage ./pkgs/openresty-luajit2 {};
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

  phpinfoCompare = callPackage ./pkgs/phpinfo-compare {};
  maketestPhp = {php, image, rootfs, ...}@args:
    callPackage ./tests/apache.nix args;
  maketestSsh = {image, rootfs, ...}@args:
    callPackage ./tests/ssh.nix args;
  maketestPhpNginxPrivate = {php, image, rootfs, ...}@args:
    callPackage ./tests/nginx-private.nix args;
  maketestPhpPrivate = {php, image, rootfs, ...}@args:
    callPackage ./tests/apache-private.nix args;
  dockerNodeTest = import ./tests/dockerNodeTest.nix;
  phpinfo = super.writeScript "phpinfo.php" "<?php phpinfo(); ?>";
  parser3 = callPackage ./pkgs/parser {};
  testDiffPy = import ./tests/scripts/deepdiff.nix;
  wordpressScript = import ./tests/scripts/wordpress.nix;
  wrkScript = import ./tests/scripts/wrk.nix;
  containerStructureTest = import ./tests/scripts/container-structure-test.nix;
  runCurl = url: output:
    builtins.concatStringsSep " " [
      "curl"
      "--connect-timeout"
      "30"
      "--fail"
      "--silent"
      "--output"
      output
      url
    ];
  bitrixServerTest = ./tests/bitrix_server_test.php;
  testPhpMariadbConnector = import ./tests/scripts/test-php-mariadb-connector.nix;
  testImages = import ./tests/images.nix;
}
