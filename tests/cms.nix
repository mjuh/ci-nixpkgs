{ nixpkgs # provided by callPackage by default
, pkgs    # provided by callPackage by default
, lib     # provided by callPackage by default
, testName
, containerImageApache
, containerImageCMS
, image
}:

# Where:
#
# - containerImageApache is path to image tarball
# - containerImageCMS is path to image tarball
# - IMAGE is image url, e.g. docker-registry.intr/apps/moodle:latest

with lib;

let
  inherit (pkgs) writeScript;

  dockerNodeTest = import ./dockerNodeTest.nix;

  loadContainers = { extraContainers ? [ ] }:
    writeScript "pullContainers.sh" ''
      #!${pkgs.bash}/bin/bash
      PATH=${pkgs.docker}/bin:$PATH
      ${builtins.concatStringsSep "; "
      (map (container: "docker load --input ${container}")
        ([ containerImageCMS containerImageApache ] ++ extraContainers))}
    '';

  runApache = writeScript "runApache.sh" ''
    #!${pkgs.bash}/bin/bash
    PATH=${pkgs.docker}/bin:$PATH
    set -e -x
    rsync -av /etc/{passwd,group,shadow} /opt/etc/ > /dev/null
    ${
      (lib.importJSON
        (containerImageApache.baseJson)).config.Labels."ru.majordomo.docker.cmd"
    } &
  '';

  runCms = writeScript "runCms.sh" ''
    #!${pkgs.bash}/bin/bash
    PATH=${pkgs.docker}/bin:$PATH
    exec -a "$0" docker run                              \
        --rm                                             \
        --user 12345:100                                 \
        --volume /home/u12345/example.com/www:/workdir   \
        --env DB_NAME=b12345_123456                      \
        --env DB_PASSWORD=qwerty123admin                 \
        --env DB_USER=u12345_123456                      \
        --env DB_HOST=127.0.0.1                          \
        --env ADMIN_PASSWORD=qwerty123admin              \
        --env ADMIN_USERNAME=admin                       \
        --env ADMIN_EMAIL=root@example.com               \
        --env APP_TITLE=example.com                      \
        --env PROTOCOL=http                              \
        --env DOMAIN_NAME=example.com                    \
        --env DOCUMENT_ROOT=/home/u12345/example.com/www \
        --network=host                                   \
        --workdir /workdir                               \
        ${image}
  '';

  mariadbInit = ''
    CREATE USER 'u12345_123456'@'%' IDENTIFIED BY 'qwerty123admin';
    CREATE DATABASE b12345_123456;
    GRANT ALL PRIVILEGES ON b12345_123456 . * TO 'u12345_123456'@'%';
    FLUSH PRIVILEGES;
  '';

  runMariadb = writeScript "runMariadb.sh" ''
    #!${pkgs.bash}/bin/bash
    PATH=${pkgs.docker}/bin:$PATH
    set -ex
    install -Dm644 ${
      pkgs.writeText "mariadb-init.sql" mariadbInit
    } /tmp/mariadb/init.sql
    docker run --env MYSQL_ROOT_PASSWORD=root123pass --volume /tmp/mariadb:/tmp/mariadb --detach --rm --name mariadb --network host mysql:5.5
    sleep 15 # wait for container start up
    docker exec mariadb mysql -h localhost -u root -proot123pass -e "source /tmp/mariadb/init.sql;"
  '';

  vmTemplate = {
    environment.etc.testBitrix.source = runMariadb;
    virtualisation = {
      cores = 3;
      memorySize = 4 * 1024;
      diskSize = 4 * 1024;
      docker.enable = true;
    };
    networking.extraHosts = "127.0.0.1 example.com";
    users.users = {
      u12345 = {
        isNormalUser = true;
        password = "secret";
        uid = 12345;
      };
      www-data = {
        isNormalUser = false;
        uid = 33;
      };
    };

    # Environment variables for Apache container
    environment.variables.SECURITY_LEVEL = "default";
    environment.variables.SITES_CONF_PATH =
      "/etc/apache2-php72-default/sites-enabled";
    environment.variables.SOCKET_HTTP_PORT = "80";

    boot.initrd.postMountCommands = ''
      for dir in /apache2-php72-default /opcache /home \
                 /opt/postfix/spool/public /opt/postfix/spool/maildrop \
                 /opt/postfix/lib; do
          mkdir -p /mnt-root$dir
      done

      mkdir /mnt-root/apache2-php72-default/sites-enabled

      # Used as Docker volume
      #
      mkdir -p /mnt-root/opt/etc
      for file in group gshadow passwd shadow; do
        mkdir -p /mnt-root/opt/etc
        cp -v /etc/$file /mnt-root/opt/etc/$file
      done
      #
      mkdir -p /mnt-root/opcache/example.com
      chmod -R 1777 /mnt-root/opcache

      mkdir -p /mnt-root/etc/apache2-php72-default/sites-enabled/
      cat <<EOF > /mnt-root/etc/apache2-php72-default/sites-enabled/5d41c60519f4690001176012.conf
      <VirtualHost 127.0.0.1:80>
          ServerName example.com
          ServerAlias www.example.com
          ScriptAlias /cgi-bin /home/u12345/example.com/www/cgi-bin
          DocumentRoot /home/u12345/example.com/www
          <Directory /home/u12345/example.com/www>
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
          php_admin_value opcache.revalidate_freq 0
          php_admin_value opcache.file_cache "/opcache/example.com"
          <IfModule mod_setenvif.c>
              SetEnvIf X-Forwarded-Proto https HTTPS=on
              SetEnvIf X-Forwarded-Proto https PORT=443
          </IfModule>
          <IfFile  /home/u12345/logs>
          CustomLog /home/u12345/logs/www.example.com-access.log common-time
          ErrorLog /home/u12345/logs/www.example.com-error_log
          </IfFile>
          MaxClientsVHost 20
          AssignUserID #12345 #100
      </VirtualHost>
      EOF

      mkdir -p /mnt-root/home/u12345/example.com/www
      chown 12345:100 -R /mnt-root/home/u12345
    '';
  };

in [
  (lib.maketest ({ pkgs, lib, ... }: {
    name = testName + "-mariadb-5.5";
    nodes = { dockerNode = { pkgs, ... }: vmTemplate; };

    testScript = [''
      print "Tests entry point.\n";
      startAll;

      print "Start services.\n";
      $dockerNode->sleep(10);
    ''] ++ [

      (dockerNodeTest {
        description = "Load containers";
        action = "succeed";
        command = loadContainers {
          extraContainers = [
            (pkgs.dockerTools.pullImage {
              imageName = "mysql";
              imageDigest =
                "sha256:12da85ab88aedfdf39455872fb044f607c32fdc233cd59f1d26769fbf439b045";
              sha256 = "0cw4hvjif5pnb774vxxh45nbsa8jrnm6bvz589s4v3d7iyqy5s3f";
              finalImageName = "mysql";
              finalImageTag = "5.5";
            })
          ];
        };
      })

      (dockerNodeTest {
        description = "Start MariaDB container";
        action = "succeed";
        command = runMariadb;
      })

      (dockerNodeTest {
        description = "Start Apache container";
        action = "succeed";
        command = runApache;
      })

      (dockerNodeTest {
        description = "Install CMS";
        action = "succeed";
        command = runCms;
      })

      (dockerNodeTest {
        description = "Take CMS screenshot";
        action = "succeed";
        command = builtins.concatStringsSep " " [
          "${pkgs.firefox}/bin/firefox"
          "--headless"
          "--screenshot=/tmp/xchg/coverage-data/cms.png"
          "http://example.com/"
        ];
      })
    ];
  }) { })

  (lib.maketest ({ pkgs, lib, ... }: {
    name = testName + "-mariadb-nix-upstream";
    nodes = {
      dockerNode = { pkgs, ... }:
        vmTemplate // {
          services.mysql.enable = true;
          services.mysql.initialScript = pkgs.writeText "mariadb-init.sql" ''
            ALTER USER root@localhost IDENTIFIED WITH unix_socket;
            DELETE FROM mysql.user WHERE password = ''' AND plugin = ''';
            DELETE FROM mysql.user WHERE user = ''';
            ${mariadbInit}
          '';
          services.mysql.package = pkgs.mariadb;
        };
    };

    testScript = [''
      print "Tests entry point.\n";
      startAll;

      print "Start services.\n";
      $dockerNode->waitForUnit("mysql");
      $dockerNode->sleep(10);
    ''] ++ [

      (dockerNodeTest {
        description = "Load containers";
        action = "succeed";
        command = loadContainers { };
      })

      (dockerNodeTest {
        description = "Start Apache container";
        action = "succeed";
        command = runApache;
      })

      (dockerNodeTest {
        description = "Install CMS";
        action = "succeed";
        command = runCms;
      })

      (dockerNodeTest {
        description = "Take CMS screenshot";
        action = "succeed";
        command = builtins.concatStringsSep " " [
          "${pkgs.firefox}/bin/firefox"
          "--headless"
          "--screenshot=/tmp/xchg/coverage-data/cms.png"
          "http://example.com/"
        ];
      })
    ];
  }) { })
]
