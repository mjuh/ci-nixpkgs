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
    # php4 = (callPackage ./pkgs/php {}).php4;
    # php52 = (callPackage ./pkgs/php {}).php52;
    # php53 = (callPackage ./pkgs/php {}).php53;
    # php54 = (callPackage ./pkgs/php {}).php54;
    # php55 = (callPackage ./pkgs/php {}).php55;
    # php56 = (callPackage ./pkgs/php {}).php56;
    php70 = (callPackage ./pkgs/php {}).php70;
    # php71 = (callPackage ./pkgs/php {}).php71;
    # php72 = (callPackage ./pkgs/php {}).php72;
    # php73 = (callPackage ./pkgs/php {}).php73;
  };

in
majordomoPkgs // { inherit majordomoPkgs; }
