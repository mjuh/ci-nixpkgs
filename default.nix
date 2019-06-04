# Majordomo nix overlay

self: super:

rec {
  inherit (super) stdenv fetchFromGitHub lua51Packages gettext callPackage;

  lib = super.lib // (import ./lib.nix { pkgs = self; });

  mjHttpErrorPages = callPackage ./pkgs/mj-http-error-pages {};
  openrestyLuajit2 = callPackage ./pkgs/openresty-luajit2 {}; 
  nginxModules = super.nginxModules // (callPackage ./pkgs/nginx-modules {});
  luajitPackages = super.luajitPackages // (callPackage ./pkgs/luajit-packages {});
}
