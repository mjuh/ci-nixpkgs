{ stdenv, mariadb, symlinkJoin, openssl }:

let
  mariadb-connector-c = (mariadb.override{ inherit openssl; }).connector-c.overrideAttrs (_: rec {
    patches = [ ./php_mysqli.so_required_symbols_export.patch ];
  });
in
  
symlinkJoin {
  name = "mariadb-connector-c-lib-dev";
  paths = [ mariadb-connector-c.dev mariadb-connector-c.out ];
}
