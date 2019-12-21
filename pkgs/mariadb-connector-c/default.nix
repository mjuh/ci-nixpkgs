{ stdenv, mariadb, symlinkJoin, openssl }:

let
  mariadb-connector-c = (mariadb.override{ inherit openssl; }).connector-c.overrideAttrs (oldAttrs: {
    patches = [ ./php_mysqli.so_required_symbols_export.patch ];
    postInstall = oldAttrs.postInstall or "" + ''
              ln -sf $out/lib/mariadb/libmysqlclient.so  $out/lib/mariadb/libmysqlclient.so.18
              ln -sf $out/lib/mariadb/libmysqlclient.so  $out/lib/mariadb/libmysqlclient.so.18.0.0
              ln -sf $out/lib/mariadb/libmysqlclient.so  $out/lib/mariadb/libmysqlclient_r.so.18
              ln -sf $out/lib/mariadb/libmysqlclient.so  $out/lib/mariadb/libmysqlclient_r.so.18.0.0
    '';
  });
in
  
symlinkJoin {
  name = "mariadb-connector-c-lib-dev";
  paths = [ mariadb-connector-c.dev mariadb-connector-c.out ];
}
