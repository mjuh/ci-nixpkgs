self: super:

rec {
  inherit (super) callPackage recurseIntoAttrs;
  openssl = super.openssl_1_0_2;

  postfixDeprecated = callPackage ./pkgs/postfix-deprecated {};

  php = callPackage ./pkgs/php {};
  php56 = php.php56;
  php55 = php.php55;
  php54 = php.php54;
  php53 = php.php53;
  php52 = php.php52;

  zendguard = callPackage ./pkgs/zendguard {};

  zendguard53 = zendguard.loader-php53;
  zendguard54 = zendguard.loader-php54;
  zendguard55 = zendguard.loader-php55;
  zendguard56 = zendguard.loader-php56;

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

}
