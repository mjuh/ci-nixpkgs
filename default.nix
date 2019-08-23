# Majordomo nix overlay

self: super:

let
  majordomoPkgs = rec {
    inherit (super) callPackage;

    lib = super.lib // (import ./lib.nix { pkgs = self; });

    wordpress = callPackage ./pkgs/wordpress {};

    apacheHttpd = callPackage ./pkgs/apacheHttpd {};
    apacheHttpdmpmITK = callPackage ./pkgs/apacheHttpdmpmITK {};
    connectorc = callPackage ./pkgs/connectorc {};
    ioncube = callPackage ./pkgs/ioncube {};
    libjpeg130 = callPackage ./pkgs/libjpeg130 {};
    libpng12 = callPackage ./pkgs/libpng12 {};
    luajitPackages = super.luajitPackages // (callPackage ./pkgs/luajit-packages { lua = openrestyLuajit2; });
    mjHttpErrorPages = callPackage ./pkgs/mj-http-error-pages {};

    mjperl5Packages = (callPackage ./pkgs/mjperl5Packages {}).mjPerlPackages.perls;
    mjperl5lib = (callPackage ./pkgs/mjperl5Packages {}).mjPerlPackages.mjPerlModules;
    mjPerlPackages = mjperl5Packages;
    TextTruncate = mjPerlPackages.TextTruncate;
    TimeLocal = mjPerlPackages.TimeLocal;
    PerlMagick = mjPerlPackages.PerlMagick;
    commonsense = mjPerlPackages.commonsense;
    Mojolicious = mjPerlPackages.Mojolicious;
    base = mjPerlPackages.base;
    libxml_perl = mjPerlPackages.libxml_perl;
    libnet = mjPerlPackages.libnet;
    libintl_perl = mjPerlPackages.libintl_perl;
    LWP = mjPerlPackages.LWP;
    ListMoreUtilsXS = mjPerlPackages.ListMoreUtilsXS;
    LWPProtocolHttps = mjPerlPackages.LWPProtocolHttps;
    DBI = mjPerlPackages.DBI;
    DBDmysql = mjPerlPackages.DBDmysql;
    CGI = mjPerlPackages.CGI;
    FilePath = mjPerlPackages.FilePath;
    DigestPerlMD5 = mjPerlPackages.DigestPerlMD5;
    DigestSHA1 = mjPerlPackages.DigestSHA1;
    FileBOM = mjPerlPackages.FileBOM;
    GD = mjPerlPackages.GD;
    LocaleGettext = mjPerlPackages.LocaleGettext;
    HashDiff = mjPerlPackages.HashDiff;
    JSONXS = mjPerlPackages.JSONXS;
    POSIXstrftimeCompiler = mjPerlPackages.POSIXstrftimeCompiler;
    perl = mjPerlPackages.perl;

    nginxModules = super.nginxModules // (callPackage ./pkgs/nginx-modules {});
    openrestyLuajit2 = callPackage ./pkgs/openresty-luajit2 {};
    pcre831 = callPackage ./pkgs/pcre831 {};
    penlight = luajitPackages.penlight;
    postfix = callPackage ./pkgs/postfix {};
    sockexec = callPackage ./pkgs/sockexec {};
    zendoptimizer = callPackage ./pkgs/zendoptimizer {};

    zendguard = callPackage ./pkgs/zendguard {};

    zendguard53 = zendguard.loader-php53;
    zendguard54 = zendguard.loader-php54;
    zendguard55 = zendguard.loader-php55;
    zendguard56 = zendguard.loader-php56;

    libjpegv6b = callPackage ./pkgs/libjpegv6b {};

    imagemagick68 = callPackage ./pkgs/imagemagick68 {};

    php = callPackage ./pkgs/php {};

    php4 = php.php4;
    php52 = php.php52;
    php53 = php.php53;
    php54 = php.php54;
    php55 = php.php55;
    php56 = php.php56;
    php70 = php.php70;
    php71 = php.php71;
    php72 = php.php72;
    php73 = php.php73;

    phpPackages = callPackage ./pkgs/php-packages {};

    php52Packages = phpPackages.php52Packages;
    php52-dbase = php52Packages.dbase;
    php52-imagick = php52Packages.imagick;
    php52-intl = php52Packages.intl;
    php52-timezonedb = php52Packages.timezonedb;
    php52-zendopcache = php52Packages.zendopcache;

    php53Packages = phpPackages.php53Packages;
    php53-dbase = php53Packages.dbase;
    php53-imagick = php53Packages.imagick;
    php53-intl = php53Packages.intl;
    php53-timezonedb = php53Packages.timezonedb;
    php53-zendopcache = php53Packages.zendopcache;

    php54Packages = phpPackages.php54Packages;
    php54-imagick = php54Packages.imagick;
    php54-memcached = php54Packages.memcached;
    php54-redis = php54Packages.redis;
    php54-timezonedb = php54Packages.timezonedb;
    php54-zendopcache = php54Packages.zendopcache;

    php55Packages = phpPackages.php55Packages;
    php55-dbase = php55Packages.dbase;
    php55-imagick = php55Packages.imagick;
    php55-intl = php55Packages.intl;
    php55-timezonedb = php55Packages.timezonedb;

    php56Packages = phpPackages.php56Packages;
    php56-dbase = php56Packages.dbase;
    php56-imagick = php56Packages.imagick;
    php56-intl = php56Packages.intl;
    php56-timezonedb = php56Packages.timezonedb;

    php70Packages = phpPackages.php70Packages;
    php70-imagick = php70Packages.imagick;
    php70-memcached = php70Packages.memcached;
    php70-redis = php70Packages.redis;
    php70-rrd = php70Packages.rrd;
    php70-timezonedb = php70Packages.timezonedb;

    php71Packages = phpPackages.php71Packages;
    php71-imagick = php71Packages.imagick;
    php71-libsodiumPhp = php71Packages.libsodiumPhp;
    php71-memcached = php71Packages.memcached;
    php71-redis = php71Packages.redis;
    php71-rrd = php71Packages.rrd;
    php71-timezonedb = php71Packages.timezonedb;

    php72Packages = phpPackages.php72Packages;
    php72-imagick = php72Packages.imagick;
    php72-memcached = php72Packages.memcached;
    php72-redis = php72Packages.redis;
    php72-rrd = php72Packages.rrd;
    php72-timezonedb = php72Packages.timezonedb;

    php73Packages = phpPackages.php73Packages;
    php73-imagick = php73Packages.imagick;
    php73-memcached = php73Packages.memcached;
    php73-redis = php73Packages.redis;
    php73-rrd = php73Packages.rrd;
    php73-timezonedb = php73Packages.timezonedb;

    pure-ftpd = callPackage ./pkgs/pure-ftpd {};

    docker-image = callPackage ./pkgs/docker/docker-image.nix {};
    php52-image = docker-image.php52-image;
    php53-image = docker-image.php53-image;
    php54-image = docker-image.php54-image;
    php55-image = docker-image.php55-image;
    php56-image = docker-image.php56-image;
    php70-image = docker-image.php70-image;
    php71-image = docker-image.php71-image;
    php72-image = docker-image.php72-image;
    php73-image = docker-image.php73-image;

    php-tests = callPackage ./pkgs/docker/tests.nix {
      image = docker-image;
    };
    php52-test = php-tests.php52;
    php53-test = php-tests.php53;
    php54-test = php-tests.php54;
    php55-test = php-tests.php55;
    php56-test = php-tests.php56;
    php70-test = php-tests.php70;
    php71-test = php-tests.php71;
    php72-test = php-tests.php72;
    php73-test = php-tests.php73;

    phpinfoCompare = callPackage ./pkgs/phpinfo-compare {};
  };

in
majordomoPkgs // { inherit majordomoPkgs; }
