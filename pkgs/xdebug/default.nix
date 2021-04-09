{ lib, php, xdebug_version ? "3.0.4" }:

let 
  xdebugVersionHashMap = {
    "3.0.4" = "1bvjmnx9bcfq4ikp02kiqg0f7ccgx4mkmz5d7g6v0d263x4r0wmj";
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
