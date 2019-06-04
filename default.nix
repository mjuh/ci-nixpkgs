# Majordomo nix overlay

self: super:

rec {
  inherit (super) callPackage;

  lib = super.lib // (import ./lib.nix { pkgs = self; });

  mjHttpErrorPages = callPackage ./pkgs/mj-http-error-pages {};
  openrestyLuajit2 = callPackage ./pkgs/openresty-luajit2 {};
  sockexec = callPackage ./pkgs/sockexec {}; 
  nginxModules = super.nginxModules // (callPackage ./pkgs/nginx-modules {});
  luajitPackages = super.luajitPackages // (callPackage ./pkgs/luajit-packages { lua = openrestyLuajit2; });
}
