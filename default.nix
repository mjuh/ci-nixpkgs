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
    perlPackages = super.perlPackages // (callPackage ./pkgs/perlPackages {});
    ioncube = callPackage ./pkgs/ioncube {};
    connectorc = callPackage ./pkgs/connectorc {};
    pcre831 = callPackage ./pkgs/pcre831 {};
    libjpeg130 = callPackage ./pkgs/libjpeg130 {};
    libpng12 = callPackage ./pkgs/libpng12 {};
    # php4 = (callPackage ./pkgs/php {}).php4;
    php52 = (callPackage ./pkgs/php {}).php52;
    php53 = (callPackage ./pkgs/php {}).php53;
    php53dev = (callPackage ./pkgs/php {}).php53.dev;
    php54 = (callPackage ./pkgs/php {}).php54;
    php54dev = (callPackage ./pkgs/php {}).php54.dev;
    php55 = (callPackage ./pkgs/php {}).php55;
    php55dev = (callPackage ./pkgs/php {}).php55.dev;
    php56 = (callPackage ./pkgs/php {}).php56;
    php56dev = (callPackage ./pkgs/php {}).php56.dev;
    php70 = (callPackage ./pkgs/php {}).php70;
    php70dev = (callPackage ./pkgs/php {}).php70.dev;
    php71 = (callPackage ./pkgs/php {}).php71;
    php71dev = (callPackage ./pkgs/php {}).php71.dev;
    php72 = (callPackage ./pkgs/php {}).php72;
    php72dev = (callPackage ./pkgs/php {}).php72.dev;
    php73 = (callPackage ./pkgs/php {}).php73;
    php73dev = (callPackage ./pkgs/php {}).php73.dev;
  };

in
majordomoPkgs // { inherit majordomoPkgs; }
