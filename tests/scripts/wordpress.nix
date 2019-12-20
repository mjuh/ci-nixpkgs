{ pkgs, lib ? pkgs.lib, php
, wordpress ? (pkgs.callPackage ../../pkgs/wordpress { }) }:

with lib;
with pkgs;

let
  phpVersion = "php" + lib.versions.major php.version
    + lib.versions.minor php.version;
  wpConfig = writeScript "wp-config.php" (builtins.readFile ../wp-config.php);

  wordpressUpgrade = stdenv.mkDerivation rec {
    inherit (lib.traceVal wordpress)
    ;
    src = wordpress.src;
    name = "wordpress-upgrade";
    configurePhase = ''
      sed -i '/^.*The password you chose during the install.*$/d' wp-admin/includes/upgrade.php
    '';
    installPhase = ''
      mkdir -p $out/share/wordpress/wp-admin/includes
      cp wp-admin/includes/upgrade.php $out/share/wordpress/wp-admin/includes
    '';
  };

  wpInstallScript = import ../wp-install.nix;

in writeScript "wordpress.sh" ''
  #!${bash}/bin/bash
  # Install and test WordPress.
  exec &> /tmp/xchg/coverage-data/wordpress.log

  set -e -x

  tar -v -C /home/u12/${phpVersion}.ru/www --strip-components=1 -xf ${wordpress.src}

  cp -v ${wordpressUpgrade}/share/wordpress/wp-admin/includes/upgrade.php \
    /home/u12/${phpVersion}.ru/www/wp-admin/includes/upgrade.php

  cp -v ${wpConfig} /home/u12/${phpVersion}.ru/www/wp-config.php

  chown u12: -R /home/u12

  cp -v ${wpInstallScript {
    inherit pkgs;
    inherit php;
  }} \
    /home/u12/${phpVersion}.ru/www/wp-admin/my-install
  cd /home/u12/${phpVersion}.ru/www/wp-admin
  chmod a+x my-install
  ./my-install Congratulations wordpress root@localhost secret
  cd -

  mysql -e "UPDATE wp_options SET option_value = 'php73.ru' WHERE option_name = 'home' OR option_name = 'siteurl';" wordpress

  curl --silent http://${phpVersion}.ru/ | grep Congratulations
''
