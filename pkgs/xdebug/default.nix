{ lib, php, xdebug_version ? "3.0.4" }:

let 
  xdebugVersionHashMap = {
    "3.0.4" = "1bvjmnx9bcfq4ikp02kiqg0f7ccgx4mkmz5d7g6v0d263x4r0wmj"; # PHP 7.2 +
    "2.9.8" = ""; # PHP 7.1 
    "2.8.1" = ""; # PHP 7.0
    "2.4.1" = ""; # PHP 5.2
  };

in lib.buildPhpPackage rec {
  name = "xdebug";
  version = xdebug_version;
  sha256 = xdebugVersionHashMap."${version}";
  zend_extension = true;

  inherit php;
  doCheck = true;
  checkTarget = "test";
}
