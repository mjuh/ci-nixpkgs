self: super:

rec {
  inherit (super) callPackage recurseIntoAttrs;
  openssl = super.openssl_1_0_2;

  postfixDeprecated = callPackage ./pkgs/postfix-deprecated {};

  php52 = callPackage ./pkgs/php/php52.nix {};
  php53 = callPackage ./pkgs/php/php53.nix {};
  php54 = callPackage ./pkgs/php/php54.nix {};
  php55 = callPackage ./pkgs/php/php55.nix {};
  php56 = callPackage ./pkgs/php/php56.nix {};

  phpDeprecated = {
    inherit php52;
    inherit php53;
    inherit php54;
    inherit php55;
    inherit php56;
  };

  zendguard = callPackage ./pkgs/zendguard {};

  zendguard53 = zendguard.loader-php53;
  zendguard54 = zendguard.loader-php54;
  zendguard55 = zendguard.loader-php55;
  zendguard56 = zendguard.loader-php56;

  lib = super.lib // (import ./lib.nix { pkgs = self; });

  buildPhp52Package = args: lib.buildPhpPackage ({ php = phpDeprecated.php52; } // args);
  buildPhp53Package = args: lib.buildPhpPackage ({ php = phpDeprecated.php53; } // args);
  buildPhp54Package = args: lib.buildPhpPackage ({ php = phpDeprecated.php54; } // args);
  buildPhp55Package = args: lib.buildPhpPackage ({ php = phpDeprecated.php55; } // args);
  buildPhp56Package = args: lib.buildPhpPackage ({ php = phpDeprecated.php56; } // args);

  php52Packages = callPackage ./pkgs/php-packages/php53.nix {};
  php52-dbase = php52Packages.dbase;
  php52-imagick = php52Packages.imagick;
  php52-intl = php52Packages.intl;
  php52-timezonedb = php52Packages.timezonedb;
  php52-zendopcache = php52Packages.zendopcache;

  php53Packages = callPackage ./pkgs/php-packages/php52.nix {};
  php53-dbase = php53Packages.dbase;
  php53-imagick = php53Packages.imagick;
  php53-intl = php53Packages.intl;
  php53-timezonedb = php53Packages.timezonedb;
  php53-zendopcache = php53Packages.zendopcache;

  php54Packages = callPackage ./pkgs/php-packages/php52.nix {};
  php54-imagick = php54Packages.imagick;
  php54-memcached = php54Packages.memcached;
  php54-redis = php54Packages.redis;
  php54-timezonedb = php54Packages.timezonedb;
  php54-zendopcache = php54Packages.zendopcache;

  php55Packages = callPackage ./pkgs/php-packages/php52.nix {};
  php55-dbase = php55Packages.dbase;
  php55-imagick = php55Packages.imagick;
  php55-intl = php55Packages.intl;
  php55-timezonedb = php55Packages.timezonedb;

  php56Packages = callPackage ./pkgs/php-packages/php52.nix {};
  php56-dbase = php56Packages.dbase;
  php56-imagick = php56Packages.imagick;
  php56-intl = php56Packages.intl;
  php56-timezonedb = php56Packages.timezonedb;

}
