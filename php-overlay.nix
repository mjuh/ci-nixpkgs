self: super:

rec {
  inherit (super) callPackage callPackages recurseIntoAttrs;
  lib = super.lib // (import ./lib.nix { pkgs = self; });
  wordpress = callPackage ./pkgs/wordpress {};

  apacheHttpd = callPackage ./pkgs/apacheHttpd {};
  apacheHttpdmpmITK = callPackage ./pkgs/apacheHttpdmpmITK {};
  mysqlConnectorC = callPackage ./pkgs/mysql-connector-c {};
  connectorc = mysqlConnectorC;
  ioncube = callPackage ./pkgs/ioncube {};
  libjpeg130 = callPackage ./pkgs/libjpeg130 {};
  libpng12 = callPackage ./pkgs/libpng12 {};
  elktail = callPackage ./pkgs/elktail {};
  clamchk = callPackage ./pkgs/clamchk {};
  luajitPackages = super.luajitPackages // (callPackage ./pkgs/luajit-packages { lua = openrestyLuajit2; });
  mjHttpErrorPages = callPackage ./pkgs/mj-http-error-pages {};
  
  mperlInterpreters = callPackages ./pkgs/development/interpreters/perl {};
   inherit (mperlInterpreters) perl520;
  perl520Packages = recurseIntoAttrs perl520.pkgs;
  mjperl5Packages = (callPackage ./pkgs/mjperl5Packages { perl = perl520; perlPackages = perl520Packages; }).mjPerlPackages.perls;
  mjperl5lib = (callPackage ./pkgs/mjperl5Packages { perl = perl520; perlPackages = perl520Packages; }).mjPerlPackages.mjPerlModules;
  mjPerlPackages = mjperl5Packages;
  TextTruncate = mjPerlPackages.TextTruncate;
  TestTester = mjPerlPackages.TestTester;
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
  HTTPMessage = mjPerlPackages.HTTPMessage;
  URIEscape = mjPerlPackages.URIEscape;
  HTMLParser = mjPerlPackages.HTMLParser;
  HTTPDate = mjPerlPackages.HTTPDate;
  TryTiny = mjPerlPackages.TryTiny;
  TypesSerialiser = mjPerlPackages.TypesSerialiser;
  XMLLibXML = mjPerlPackages.XMLLibXML;
  XMLSAX = mjPerlPackages.XMLSAX;
  XMLSAXBase = mjPerlPackages.XMLSAXBase;
  Carp = mjPerlPackages.Carp;
  NetHTTP = mjPerlPackages.NetHTTP;
  DateTime = mjPerlPackages.DateTime;

  sendmail = callPackage ./pkgs/sendmail {};

  nginxModules = super.nginxModules // (callPackage ./pkgs/nginx-modules {});
  nginx = callPackage ./pkgs/nginx {};

  openrestyLuajit2 = callPackage ./pkgs/openresty-luajit2 {};
  pcre831 = callPackage ./pkgs/pcre831 {};
  penlight = luajitPackages.penlight;
  postfix = callPackage ./pkgs/postfix {};
  sockexec = callPackage ./pkgs/sockexec {};
  zendoptimizer = callPackage ./pkgs/zendoptimizer {};

  libjpegv6b = callPackage ./pkgs/libjpegv6b {};

  imagemagick68 = callPackage ./pkgs/imagemagick68 {};

  php70 = callPackage ./pkgs/php/php70.nix {};
  php71 = callPackage ./pkgs/php/php71.nix {};
  php72 = callPackage ./pkgs/php/php72.nix {};
  php73 = callPackage ./pkgs/php/php73.nix {};
  php74 = callPackage ./pkgs/php/php74.nix {};

  php73Private = callPackage ./pkgs/php/php73-private.nix {};

  php = {
    inherit php70;
    inherit php71;
    inherit php72;
    inherit php73;
    inherit php74;
    inherit php73Private;
  };

  buildPhp70Package = args: lib.buildPhpPackage ({ php = php.php70; } // args);
  buildPhp71Package = args: lib.buildPhpPackage ({ php = php.php71; } // args);
  buildPhp72Package = args: lib.buildPhpPackage ({ php = php.php72; } // args);
  buildPhp73Package = args: lib.buildPhpPackage ({ php = php.php73; } // args);
  buildPhp74Package = args: lib.buildPhpPackage ({ php = php.php74; } // args);

  buildPhp73PrivatePackage = args: lib.buildPhpPackage ({ php = php.php73Private; } // args);

  php70Packages = callPackage ./pkgs/php-packages/php70.nix {};
  php70-imagick = php70Packages.imagick;
  php70-memcached = php70Packages.memcached;
  php70-redis = php70Packages.redis;
  php70-rrd = php70Packages.rrd;
  php70-timezonedb = php70Packages.timezonedb;

  php71Packages = callPackage ./pkgs/php-packages/php71.nix {};
  php71-imagick = php71Packages.imagick;
  php71-libsodiumPhp = php71Packages.libsodiumPhp;
  php71-memcached = php71Packages.memcached;
  php71-redis = php71Packages.redis;
  php71-rrd = php71Packages.rrd;
  php71-timezonedb = php71Packages.timezonedb;

  php72Packages = callPackage ./pkgs/php-packages/php72.nix {};
  php72-imagick = php72Packages.imagick;
  php72-memcached = php72Packages.memcached;
  php72-redis = php72Packages.redis;
  php72-rrd = php72Packages.rrd;
  php72-timezonedb = php72Packages.timezonedb;

  php73Packages = callPackage ./pkgs/php-packages/php73.nix {};
  php73-imagick = php73Packages.imagick;
  php73-memcached = php73Packages.memcached;
  php73-redis = php73Packages.redis;
  php73-rrd = php73Packages.rrd;
  php73-timezonedb = php73Packages.timezonedb;

  php74Packages = callPackage ./pkgs/php-packages/php74.nix {};
  php74-imagick = php74Packages.imagick;
  php74-memcached = php74Packages.memcached;
  php74-redis = php74Packages.redis;
  php74-rrd = php74Packages.rrd;
  php74-timezonedb = php74Packages.timezonedb;


  php73PrivatePackages = callPackage ./pkgs/php-packages/php73-private.nix {};
  php73Private-imagick = php73PrivatePackages.imagick;
  php73Private-memcached = php73PrivatePackages.memcached;
  php73Private-redis = php73PrivatePackages.redis;
  php73Private-rrd = php73PrivatePackages.rrd;
  php73Private-timezonedb = php73PrivatePackages.timezonedb;

  phpPackages = {
    inherit php70Packages;
    inherit php71Packages;
    inherit php72Packages;
    inherit php73Packages;
    inherit php74Packages;
    inherit php73PrivatePackages;
  };

  pure-ftpd = callPackage ./pkgs/pure-ftpd {};

  phpinfoCompare = callPackage ./pkgs/phpinfo-compare {};

  locale = callPackage ./pkgs/locale {};

  sh = callPackage ./pkgs/sh {};

  maketestPhp = {php, image, rootfs, ...}@args:
    callPackage ./tests/apache.nix args;

  maketestPhpPrivate = {php, image, rootfs, ...}@args:
    callPackage ./tests/apache-private.nix args;

  maketestPhpNginxPrivate = {php, image, rootfs, ...}@args:
    callPackage ./tests/nginx-private.nix args;

  inetutilsMinimal = callPackage ./pkgs/inetutils-minimal {};

  deepdiff = callPackage ./pkgs/deepdiff {};

  nss-certs = callPackage ./pkgs/nss-certs {};

}
