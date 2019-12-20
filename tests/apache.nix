{ pkgs
, bash
, image
, jq
, lib
, php
, phpinfoCompare
, rootfs
, stdenv
, wordpress
, wrk2
, writeScript
, python3
, deepdiff
}:

# Run virtual machine, then container with Apache and PHP, and test it.

with lib;

let
  maketest = <nixpkgs/nixos/tests> + /make-test.nix;

  phpinfo = writeScript "phpinfo.php" ''
    <?php phpinfo(); ?>
  '';

  testDiffPy = import ./scripts/deepdiff.nix;

  runDockerImage = image: writeScript "runDockerImage.sh" ''
    #!${bash}/bin/bash
    # Run Docker image with ru.majordomo.docker.cmd label.
    set -e -x
    ${(lib.importJSON (image.baseJson)).config.Labels."ru.majordomo.docker.cmd"} &
  '';

  # Return a PHP version from ‘php’ attribute.
  php2version = php: "php" +
                    lib.versions.major php.version +
                    lib.versions.minor php.version;

  wordpressScript = import ./scripts/wordpress.nix;
  wrkScript = import ./scripts/wrk.nix;

  phpVersion = php2version php;
  domain = phpVersion + ".ru";

in

import maketest ({ pkgs, lib, ... }: {
  name = lib.concatStringsSep "-" ["apache2" phpVersion "default"];
  nodes = {
    docker = { pkgs, ... }:
      {
        virtualisation =
          {
            cores = 3;
            memorySize = 4 * 1024;
            diskSize = 4 * 1024;
            docker.enable = true;
            dockerPreloader = {
              images = [ image ];
              qcowSize = 4 * 1024;
            };
            # DEBUG:
            qemu.networkingOptions = [
              "-net nic,model=virtio" "-net user,hostfwd=tcp::2222-:22"
            ];
          };

        networking.extraHosts = "127.0.0.1 ${domain}";
        users = {
          users = {
            u12 =
              {
                isNormalUser = true;
                description = "Test user";
                password = "foobar";
              };
          };
        };

        # DEBUG:
        services.openssh.enable = true;
        services.openssh.permitRootLogin = "yes";

        environment.variables.SECURITY_LEVEL = "default";
        environment.variables.SITES_CONF_PATH = "/etc/apache2-${phpVersion}-default/sites-enabled";
        environment.variables.SOCKET_HTTP_PORT = "80";

        boot.initrd.postMountCommands = ''
                for dir in /apache2-${phpVersion}-default /opcache /home \
                           /opt/postfix/spool/public /opt/postfix/spool/maildrop \
                           /opt/postfix/lib; do
                    mkdir -p /mnt-root$dir
                done

                mkdir /mnt-root/apache2-${phpVersion}-default/sites-enabled

                # Used as Docker volume
                #
                mkdir -p /mnt-root/opt/etc
                for file in group gshadow passwd shadow; do
                  mkdir -p /mnt-root/opt/etc
                  cp -v /etc/$file /mnt-root/opt/etc/$file
                done
                #
                mkdir /opcache

                mkdir -p /mnt-root/etc/apache2-${phpVersion}-default/sites-enabled/
                cat <<EOF > /mnt-root/etc/apache2-${phpVersion}-default/sites-enabled/5d41c60519f4690001176012.conf
                <VirtualHost 127.0.0.1:80>
                    ServerName ${domain}
                    ServerAlias www.${domain}
                    ScriptAlias /cgi-bin /home/u12/${domain}/www/cgi-bin
                    DocumentRoot /home/u12/${domain}/www
                    <Directory /home/u12/${domain}/www>
                        Options +FollowSymLinks -MultiViews +Includes -ExecCGI
                        DirectoryIndex index.php index.html index.htm
                        Require all granted
                        AllowOverride all
                    </Directory>
                    AddDefaultCharset UTF-8
                  UseCanonicalName Off
                    AddHandler server-parsed .shtml .shtm
                    php_admin_flag allow_url_fopen on
                    php_admin_value mbstring.func_overload 0
                    <IfModule mod_setenvif.c>
                        SetEnvIf X-Forwarded-Proto https HTTPS=on
                        SetEnvIf X-Forwarded-Proto https PORT=443
                    </IfModule>
                    <IfFile  /home/u12/logs>
                    CustomLog /home/u12/logs/www.${domain}-access.log common-time
                    ErrorLog /home/u12/logs/www.${domain}-error_log
                    </IfFile>
                    MaxClientsVHost 20
                    AssignUserID #4165 #4165
                </VirtualHost>
                EOF

                mkdir -p /mnt-root/home/u12/${domain}/www
              '';

        services.mysql.enable = true;
        services.mysql.initialScript = pkgs.writeText "mariadb-init.sql" ''
              ALTER USER root@localhost IDENTIFIED WITH unix_socket;
              DELETE FROM mysql.user WHERE password = ''' AND plugin = ''';
              DELETE FROM mysql.user WHERE user = ''';
              CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'password123';
              FLUSH PRIVILEGES;
            '';
        services.mysql.ensureDatabases = [ "wordpress" ];
        services.mysql.ensureUsers = [{
          name = "wordpress_user";
          ensurePermissions = {
            "wordpress.*" = "ALL PRIVILEGES";
          };
        }];
        services.mysql.package = pkgs.mariadb;
      };
  };

  testScript = [
    ''
          startAll;

          print "Start services.\n";
          $docker->waitForUnit("mysql");
          $docker->execute("${runDockerImage image}");
          $docker->sleep(10);

          print "Get phpinfo.\n";
          $docker->execute("cp -v ${phpinfo} /home/u12/${domain}/www/phpinfo.php");
          $docker->succeed("curl --connect-timeout 30 -f --silent --output /tmp/xchg/coverage-data/phpinfo.html http://${domain}/phpinfo.php");

          print "Get server-status.\n";
          $docker->succeed("curl --connect-timeout 30 -f --silent --output /tmp/xchg/coverage-data/server-status.html http://127.0.0.1/server-status");

          print "Get PHP diff.\n";
          $docker->succeed("cp -v ${./phpinfo-json.php} /home/u12/${phpVersion}.ru/www/phpinfo-json.php");
          $docker->succeed("curl --output /tmp/xchg/coverage-data/phpinfo.json --silent http://${phpVersion}.ru/phpinfo-json.php");
          $docker->succeed("${testDiffPy {
            inherit pkgs;
            sampleJson = (./. + "/${phpVersion}.json");
            output = "/tmp/xchg/coverage-data/deepdiff.html";
          }}");
          $docker->succeed("${testDiffPy {
            inherit pkgs;
            sampleJson = (./. + "/${phpVersion}.json");
            output = "/tmp/xchg/coverage-data/deepdiff-with-excludes.html";
            excludes = import ./diff-to-skip.nix;
          }}");
          $docker->succeed("${testDiffPy {
            inherit pkgs;
            sampleJson = (./. + "/web34/${phpVersion}.json");
            output = "/tmp/xchg/coverage-data/deepdiff-web34.html";
          }}");
          $docker->succeed("${testDiffPy {
            inherit pkgs;
            sampleJson = (./. + "/web34/${phpVersion}.json");
            output = "/tmp/xchg/coverage-data/deepdiff-web34-with-excludes.html";
            excludes = import ./diff-to-skip.nix;
          }}");

          print "Run Bitrix test.\n";
          $docker->succeed("cp -v ${./bitrix_server_test.php} /home/u12/${domain}/www/bitrix_server_test.php");
          $docker->succeed("curl --connect-timeout 30 -f --silent --output /tmp/xchg/coverage-data/bitrix_server_test.html http://${domain}/bitrix_server_test.php");
        '']

  ++ optional (versionAtLeast php.version "7") [''
           $docker->execute("${wordpressScript {
             inherit pkgs;
             inherit php;
           }}");
           $docker->execute("${wrkScript {
             inherit pkgs;
             url = "http://${phpVersion}.ru/";
           }}");
        ''];
})
