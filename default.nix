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
    pure-ftpd = callPackage ./pkgs/pure-ftpd {};
  };

in
majordomoPkgs // { inherit majordomoPkgs; }
