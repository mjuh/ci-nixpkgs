final: prev:

let
  inherit (prev) callPackage symlinkJoin;

  withMajordomoCacert = { pkgs }: rec {
    cacert = callPackage ./pkgs/nss-certs { cacert = pkgs.cacert; };
    parser3 = callPackage ./pkgs/parser { inherit cacert; };
    mjHttpErrorPages = callPackage ./pkgs/mj-http-error-pages { inherit cacert; };
  };

  common-updater-scripts-php = { name, version, lib ? final.lib, writeScript ? final.writeScript }:
    let
      package-major-minor = "php" + (lib.versions.major version) + (lib.versions.minor version);
    in writeScript "updateScript-${name}.sh" ''
      #!/usr/bin/env nix-shell
      #! nix-shell -i bash -p curl jq gnugrep common-updater-scripts git
      version="$(curl -s 'https://www.php.net/releases/index.php?json&version=${lib.versions.majorMinor version}' | jq .version)"
      update-source-version --file=pkgs/${package-major-minor}/default.nix ${package-major-minor} "$version"
    '';

in rec {
  lib = prev.lib // (import ./pkgs/lib { pkgs = final; });

  dockerTools = prev.dockerTools // {
  buildLayeredImage = { topLayer ? null, minSize ? 10485760, contents, ... }@args:
    let
      popularityContestSized = callPackage ./pkgs/popularity-contest-sized {};
      referencesByPopularity = popularityContestSized topLayer minSize;
      dockerTools = prev.dockerTools.override { inherit referencesByPopularity; };
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
    paths = [ prev.pcre.out prev.pcre.dev];
  };

  libxpm-lib-dev = symlinkJoin {
    name = "libxpm-lib-dev";
    paths = [ prev.xorg.libXpm.out prev.xorg.libXpm.dev];
  };

  libpng-lib-dev = symlinkJoin {
    name = "libpng-lib-dev";
    paths = [ prev.libpng.out prev.libpng.dev ];
  };

  libjpeg-lib-dev = symlinkJoin {
    name = "libjpeg-lib-dev";
    paths = [ prev.libjpeg.out prev.libjpeg.dev ];
  };

  libtiff-lib-dev = symlinkJoin {
    name = "libtiff-lib-dev";
    paths = [ prev.libtiff.out prev.libtiff.dev ];
  };

  freetype-all = symlinkJoin {
    name = "freetype-all";
    paths = [ prev.freetype prev.freetype.dev ];
  };

  lcms2-lib-dev = symlinkJoin {
    name = "lcms2-lib-dev";
    paths = [ prev.lcms2.out prev.lcms2.dev ];
  };

  zlib-all = symlinkJoin {
    name = "zlib-all";
    paths = [ prev.zlib prev.zlib.dev ];
  };

  mariadbConnectorC = callPackage ./pkgs/mariadb-connector-c {};

  nss-certs = callPackage ./pkgs/nss-certs { cacert = prev.cacert; };

  inherit (withMajordomoCacert { pkgs = prev; }) parser3 mjHttpErrorPages;

  zabbix-scripts = callPackage ./pkgs/zabbix-scripts { };
  zabbix-agentd-conf = callPackage ./pkgs/zabbix-agentd-conf { };

  apacheHttpd = callPackage ./pkgs/apacheHttpd {};
  apacheHttpdmpmITK = callPackage ./pkgs/apacheHttpdmpmITK {};

  sendmail = callPackage ./pkgs/sendmail {};

  common-updater-scripts = callPackage ./pkgs/common-updater-scripts {};

  libjpegv6b = callPackage ./pkgs/libjpegv6b {};
  pcre831 = callPackage ./pkgs/pcre831 {};

  arcconf = callPackage ./pkgs/arcconf {};
  linpack-xtreme = callPackage ./pkgs/linpack-xtreme {};
  clamchk = callPackage ./pkgs/clamchk {};
  elktail = callPackage ./pkgs/elktail {};
  imagemagick68 = callPackage ./pkgs/imagemagick68 {};
  inetutilsMinimal = callPackage ./pkgs/inetutils-minimal {};
  influxdb-subscription-cleaner = callPackage ./pkgs/influxdb-subscription-cleaner {};
  ioncube = callPackage ./pkgs/ioncube {};
  libjpeg130 = callPackage ./pkgs/libjpeg130 {};
  libjpeg8 = callPackage ./pkgs/libjpeg8 {};
  libpng12 = callPackage ./pkgs/libpng12 {};
  locale = callPackage ./pkgs/locale {};
  mcron = callPackage ./pkgs/mcron {};
  mysqlConnectorC = callPackage ./pkgs/mysql-connector-c {};
  postfix = callPackage ./pkgs/postfix {};
  postfixDeprecated = callPackage ./pkgs/postfix-deprecated {};
  pure-ftpd = callPackage ./pkgs/pure-ftpd {};
  sh = callPackage ./pkgs/sh {};
  sockexec = callPackage ./pkgs/sockexec {};
  wordpress = callPackage ./pkgs/wordpress {};

  zendguard = callPackage ./pkgs/zendguard {};
  zendguard53 = zendguard.loader-php53;
  zendguard54 = zendguard.loader-php54;
  zendguard55 = zendguard.loader-php55;
  zendguard56 = zendguard.loader-php56;
  zendoptimizer = callPackage ./pkgs/zendoptimizer {};

  withOpenSSL102 = { pkgs }: rec {
    openssl = pkgs.openssl_1_0_2;
    openssl-lib-dev = symlinkJoin {
      name = "openssl-1.0.2-lib-dev";
      paths = [ openssl.out openssl.dev ];
    };
    curl = pkgs.curl.override {
      inherit openssl;
      libssh2 = pkgs.libssh2.override { inherit openssl; };
    };
    curl-lib-dev = symlinkJoin {
      name = "curl-openssl-1.0.2-lib-dev";
      paths = [ curl.out curl.dev ];
    };
    uwimap = pkgs.uwimap.override { inherit openssl; };
    postgresql = pkgs.postgresql.override { inherit openssl; };
    mariadb-connector-c = mariadbConnectorC.override { inherit openssl; };
  };

  php44 = callPackage ./pkgs/php44 {
    postfix = sendmail;
    withOpenSSL102 = withOpenSSL102 { pkgs = prev; };
  };

  php52 = callPackage ./pkgs/php52 {
    postfix = sendmail;
    withOpenSSL102 = withOpenSSL102 { pkgs = prev; };
  };
  php52Packages = callPackage ./pkgs/php-packages/php52.nix {
    buildPhp52Package = args: lib.buildPhpPackage ({
      php = php52;
    } // args);
    buildPhp52PearPackage = args: lib.buildPhpPearPackage ({
      php = php52;
    } // args);
  };

  php53 = callPackage ./pkgs/php53 {
    postfix = sendmail;
    withOpenSSL102 = withOpenSSL102 { pkgs = prev; };
  };
  php53Packages = callPackage ./pkgs/php-packages/php53.nix {
    buildPhp53Package = args: lib.buildPhpPackage ({
      php = php53;
    } // args);
  };

  php54 = callPackage ./pkgs/php54 {
    postfix = sendmail;
    withOpenSSL102 = withOpenSSL102 { pkgs = prev; };
  };
  php54Packages = callPackage ./pkgs/php-packages/php54.nix {
    buildPhp54Package = args: lib.buildPhpPackage ({
      php = php54;
    } // args);
  };

  php55 = callPackage ./pkgs/php55 {
    postfix = sendmail;
    withOpenSSL102 = withOpenSSL102 { pkgs = prev; };
  };
  php55Packages = callPackage ./pkgs/php-packages/php55.nix {
    buildPhp55Package = args: lib.buildPhpPackage ({
      php = php55;
    } // args);
  };

  php56 = callPackage ./pkgs/php56 {
    postfix = sendmail;
    withOpenSSL102 = withOpenSSL102 { pkgs = prev; };
    updateScript = common-updater-scripts-php;
  };
  php56Packages = callPackage ./pkgs/php-packages/php56.nix {
    buildPhp56Package = args: lib.buildPhpPackage ({
      php = php56;
    } // args);
  };

  php70 = callPackage ./pkgs/php70 {
    postfix = sendmail;
    updateScript = common-updater-scripts-php;
  };
  php70Packages = callPackage ./pkgs/php-packages/php70.nix {
    buildPhp70Package = args: lib.buildPhpPackage ({
      php = php70;
      imagemagick = prev.imagemagickBig;
    } // args);
  };

  php71 = callPackage ./pkgs/php71 {
    postfix = sendmail;
    updateScript = common-updater-scripts-php;
  };
  php71Packages = callPackage ./pkgs/php-packages/php71.nix {
    buildPhp71Package = args: lib.buildPhpPackage ({
      php = php71;
      imagemagick = prev.imagemagickBig;
    } // args);
  };

  php72 = callPackage ./pkgs/php72 {
    postfix = sendmail;
    updateScript = common-updater-scripts-php;
  };
  php72Packages = callPackage ./pkgs/php-packages/php72.nix {
    buildPhp72Package = args: lib.buildPhpPackage ({
      php = php72;
      imagemagick = prev.imagemagickBig;
    } // args);
  };

  php73 = callPackage ./pkgs/php73 {
    postfix = sendmail;
    updateScript = common-updater-scripts-php;
  };
  php73Packages = callPackage ./pkgs/php-packages/php73.nix {
    buildPhp73Package = args: lib.buildPhpPackage ({
      php = php73;
      imagemagick = prev.imagemagickBig;
    } // args);
  };

  php74 = callPackage ./pkgs/php74 {
    postfix = sendmail;
    updateScript = common-updater-scripts-php;
  };
  php74Packages = callPackage ./pkgs/php-packages/php74.nix {
    buildPhp74Package = args: lib.buildPhpPackage ({
      php = php74;
      imagemagick = prev.imagemagickBig;
    } // args);
  };

  php80 = callPackage ./pkgs/php80 {
    postfix = sendmail;
  };
  php80Packages = callPackage ./pkgs/php-packages/php80.nix {
    buildPhp80Package = args: lib.buildPhpPackage ({
      php = php80;
      imagemagick = prev.imagemagickBig;
    } // args);
  };

  php74Personal = callPackage ./pkgs/php74/default.nix {
    personal = true;
    updateScript = common-updater-scripts-php;
  };
  php74PersonalFpm = callPackage ./pkgs/php74/default.nix {
    personal = true;
    enableFpm = true;
    updateScript = common-updater-scripts-php;
  };
  php74PersonalPackages = callPackage ./pkgs/php-packages/php74-personal.nix {
    buildPhp74PersonalPackage = args: lib.buildPhpPackage ({
      php = php74Personal;
      imagemagick = prev.imagemagickBig;
    } // args);
  };

  mperlInterpreters = callPackage ./pkgs/development/interpreters/perl {};
  inherit (mperlInterpreters) perl520;
  mj-perl-packages = (callPackage ./pkgs/mjperl5Packages { perl = perl520; perlPackages = perl520.pkgs; });
  mjPerlPackages = mj-perl-packages.mjPerlPackages;
  mjperl5Packages = mjPerlPackages.perls;
  mjperl5lib = mjPerlPackages.mjPerlModules;

  luaInterpreters = prev.luaInterpreters // rec {
    openrestyLuajit2 = callPackage ./pkgs/openresty-luajit2 { final = openrestyLuajit2; };
  };
  openrestyLuajit2 = luaInterpreters.openrestyLuajit2;
  openrestyPackages = openrestyLuajit2.pkgs;
  nginx = callPackage ./pkgs/nginx {};
  nginxModules = callPackage ./pkgs/nginx-modules {};

  python37mj = with prev; python37.override {
    packageOverrides = callPackage ./pkgs/python-packages/default.nix { python = python37; };
  };
  python38mj = with prev; python38.override {
    packageOverrides = callPackage ./pkgs/python-packages/default.nix { python = python38; };
  };

  mkPythonCustomerPkgsSet = python: with prev;
    rec {
      runPyPkgs = with python.pkgs; [ mysqlclient pandas lxml pillow ];
      buildPyPkgs = with python.pkgs; [ pip certifi cython ] ++ runPyPkgs;
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

  mjexim = callPackage ./pkgs/mjexim {};
  mjpigeonhole = callPackage ./pkgs/mjpigeonhole {};
  mjdovecot = callPackage ./pkgs/mjdovecot {};

  icu52 = callPackage ./pkgs/icu52 { };
  mj-phantomjs = callPackage ./pkgs/mj-phantomjs/default.nix {};

  automake113x = callPackage ./pkgs/automake113 { };
  cgrouptuner = callPackage ./pkgs/cgrouptuner { };
  libcgroup = callPackage ./pkgs/libcgroup { };

  phpinfoCompare = callPackage ./pkgs/phpinfo-compare {};

  maketestPhp = {php, image, rootfs, ...}@args:
    callPackage ./tests/apache.nix args // { pkgs = final; };
  maketestPerl = {image, rootfs, ...}@args:
    callPackage ./tests/apache-perl.nix args;
  maketestNginx = {image, ...}@args:
    callPackage ./tests/nginx.nix args;
  maketestUwsgi = {image, ...}@args:
    callPackage ./tests/uwsgi.nix args;
  maketestSsh = {image, ...}@args:
    callPackage ./tests/ssh.nix args;
  maketestPhpNginxPrivate = {php, image, rootfs, ...}@args:
    callPackage ./tests/nginx-private.nix args;
  maketestCms = {containerImageApache, containerImageCMS, image, ...}@args:
    callPackage ./tests/cms.nix args;
  dockerNodeTest = import ./tests/dockerNodeTest.nix;
  phpinfo = prev.writeScript "phpinfo.php" "<?php phpinfo(); ?>";
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
  man-derivations-packages = packages: (builtins.map (p: prev.lib.getOutput "man" p) packages) ++ packages;

  vulnix = (prev.vulnix.overrideAttrs (old: rec {
    inherit (old) pname;
    version = "1.9.4";
    src = prev.pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "06dpdsnz1ih0syas3x25s557qpw0f4kmypvxwaffm734djg8klmi";
    };
  })).override { pythonPackages = python37mj.pkgs; };

  bashhub-client = callPackage ./pkgs/bashhub-client { };

  redis-cli = callPackage ./pkgs/redis { };

  containers = let
    container-drvs = args: services:
      lib.listToAttrs (map (name: {
        inherit name;
        value = (import (fetchGit {
          url = "git+ssh://git@gitlab.intr/webservices/" + name + ".git";
          ref = "master";}) args);
      }) services);
    webservices = [
      "apache2-perl518"
      "apache2-php52"
      "apache2-php53"
      "apache2-php54"
      "apache2-php55"
      "apache2-php56"
      "apache2-php70"
      "apache2-php71"
      "apache2-php72"
      "apache2-php73"
      "apache2-php74"
      "cron"
      "ftpserver"
      "nginx"
      "nginx-php73-personal"
      "postfix"
      "ssh-guest-room"
      "ssh-sup-room"
      "uwsgi-python37"
      "webftp-new"
    ];
  in container-drvs { nixpkgs = import <nixpkgs> { overlays = [ (import ./.) ]; }; } webservices //
     container-drvs { } [ "memcached" "redis" "rsyslog" "ssh2docker" "http-fileserver" "apache2-php74-personal" ];

  personal-service-entrypoint = callPackage (import ./pkgs/personal-service).entrypoint {};

  notDerivations = [
    "bitrixServerTest"
    "containers"
    "containerStructureTest"
    "dockerNodeTest"
    "dockerTools"
    "lib"
    "luaInterpreters"
    "maketestCms"
    "maketestNginx"
    "maketestPerl"
    "maketestPhp"
    "maketestPhpNginxPrivate"
    "maketestSsh"
    "maketestUwsgi"
    "man-derivations-packages"
    "mjperl5lib"
    "mjperl5Packages"
    "mj-perl-packages"
    "mjPerlPackages"
    "mkPythonCustomerPkgsSet"
    "mperlInterpreters"
    "nginxModules"
    "notDerivations"
    "openrestyPackages"
    "php52Packages"
    "php53Packages"
    "php54Packages"
    "php55Packages"
    "php56Packages"
    "php70Packages"
    "php71Packages"
    "php72Packages"
    "php73Packages"
    "php74Packages"
    "php74PersonalPackages"
    "php80Packages"
    "phpinfo"
    "python37mjCustomerPkgsSet"
    "python38mjCustomerPkgsSet"
    "runCurl"
    "runCurlGrep"
    "testDiffPy"
    "testImages"
    "testPhpMariadbConnector"
    "withOpenSSL102"
    "wordpressScript"
    "wrkScript"
    "zendguard"
  ];
}
