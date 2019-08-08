# Majordomo nix overlay

self: super:

let
  majordomoPkgs = rec {
    inherit (super) callPackage;

    lib = super.lib // (import ./lib.nix { pkgs = self; });

    mjHttpErrorPages = callPackage ./pkgs/mj-http-error-pages {};
    postfix = callPackage ./pkgs/postfix {};
    apacheHttpd = callPackage ./pkgs/apacheHttpd {};
    apacheHttpdmpmITK = callPackage ./pkgs/apacheHttpdmpmITK {};
    mjperl5Packages = callPackage ./pkgs/mjperl5Packages {};
    openrestyLuajit2 = callPackage ./pkgs/openresty-luajit2 {};
    sockexec = callPackage ./pkgs/sockexec {};
    nginxModules = super.nginxModules // (callPackage ./pkgs/nginx-modules {});
    luajitPackages = super.luajitPackages // (callPackage ./pkgs/luajit-packages { lua = openrestyLuajit2; });
    penlight = luajitPackages.penlight;
    perlPackages = super.perlPackages // (callPackage ./pkgs/perlPackages {});
    ioncube = callPackage ./pkgs/ioncube {};
    connectorc = callPackage ./pkgs/connectorc {};
    pcre831 = callPackage ./pkgs/pcre831 {};
    libjpeg130 = callPackage ./pkgs/libjpeg130 {};
    libpng12 = callPackage ./pkgs/libpng12 {};
    zendoptimizer = callPackage ./pkgs/zendoptimizer {};

    zendguard = (callPackage ./pkgs/zendguard {});
    zendguard53 = zendguard.loader-php53;
    zendguard54 = zendguard.loader-php54;
    zendguard55 = zendguard.loader-php55;
    zendguard56 = zendguard.loader-php56;

    libjpegv6b = callPackage ./pkgs/libjpegv6b {};

    imagemagick68 = callPackage ./pkgs/imagemagick68 {};

    php = (callPackage ./pkgs/php {});
    php4 = php.php4;
    php52 = php.php52;
    php53 = php.php53;

    php54 = php.php54;
    php54dev = php.php54.dev;

    php55 = php.php55;
    php55dev = php.php55.dev;

    php56 = php.php56;
    php56dev = php.php56.dev;

    php70 = php.php70;
    php70dev = php.php70.dev;

    php71 = php.php71;
    php71dev = php.php71.dev;

    php72 = php.php72;
    php72dev = php.php72.dev;

    php73 = php.php73;
    php73dev = php.php73.dev;

    phpPackages = (callPackage ./pkgs/php-packages {});
    php52Packages = (callPackage ./pkgs/php-packages {}).php52Packages;
    php53Packages = (callPackage ./pkgs/php-packages {}).php53Packages;
    php54Packages = (callPackage ./pkgs/php-packages {}).php54Packages;
    php55Packages = (callPackage ./pkgs/php-packages {}).php55Packages;
    php56Packages = (callPackage ./pkgs/php-packages {}).php56Packages;
    php70Packages = (callPackage ./pkgs/php-packages {}).php70Packages;
    php71Packages = (callPackage ./pkgs/php-packages {}).php71Packages;
    php72Packages = (callPackage ./pkgs/php-packages {}).php72Packages;
    php73Packages = (callPackage ./pkgs/php-packages {}).php73Packages;

    php52-dbase = php52Packages.dbase;
    php52-imagick = php52Packages.imagick;
    php52-intl = php52Packages.intl;
    php52-timezonedb = php52Packages.timezonedb;
    php52-zendopcache = php52Packages.zendopcache;

    php53-dbase = php53Packages.dbase;
    php53-imagick = php53Packages.imagick;
    php53-intl = php53Packages.intl;
    php53-timezonedb = php53Packages.timezonedb;
    php53-zendopcache = php53Packages.zendopcache;

    php54-imagick = php54Packages.imagick;
    php54-memcached = php54Packages.memcached;
    php54-redis = php54Packages.redis;
    php54-timezonedb = php54Packages.timezonedb;

    php55-dbase = php56Packages.dbase;
    php55-imagick = php56Packages.imagick;
    php55-intl = php56Packages.intl;
    php55-timezonedb = php56Packages.timezonedb;

    php56-dbase = php56Packages.dbase;
    php56-imagick = php56Packages.imagick;
    php56-intl = php56Packages.intl;
    php56-timezonedb = php56Packages.timezonedb;

    php70-imagick = php70Packages.imagick;
    php70-memcached = php70Packages.memcached;
    php70-redis = php70Packages.redis;
    php70-rrd = php70Packages.rrd;
    php70-timezonedb = php70Packages.timezonedb;

    php71-imagick = php71Packages.imagick;
    php71-libsodiumPhp = php71Packages.libsodiumPhp;
    php71-memcached = php71Packages.memcached;
    php71-redis = php71Packages.redis;
    php71-rrd = php71Packages.rrd;
    php71-timezonedb = php71Packages.timezonedb;

    php72-imagick = php72Packages.imagick;
    php72-memcached = php72Packages.memcached;
    php72-redis = php72Packages.redis;
    php72-rrd = php72Packages.rrd;
    php72-timezonedb = php72Packages.timezonedb;

    php73-imagick = php73Packages.imagick;
    php73-memcached = php73Packages.memcached;
    php73-redis = php73Packages.redis;
    php73-rrd = php73Packages.rrd;
    php73-timezonedb = php73Packages.timezonedb;

    pure-ftpd = callPackage ./pkgs/pure-ftpd {};

    python-libpython-so = callPackage ./pkgs/python-libpython-so {};
  };

in
majordomoPkgs // { inherit majordomoPkgs; }
