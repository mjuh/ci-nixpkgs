{ pkgs ? import <nixpkgs> { } }:

with pkgs;

writeScript "test-php-mariadb-connector.sh" ''
  #!${bash}/bin/bash
  ${php}/bin/php -r '$mysqlnd = function_exists("mysqli_fetch_all"); if ($mysqlnd) {exit (0);} else {exit (1);}'
''
