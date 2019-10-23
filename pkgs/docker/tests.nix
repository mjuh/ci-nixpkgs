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
, private ? false
}:

# Run virtual machine, then container with Apache and PHP, and test it.

with lib;

let
  maketest = <nixpkgs/nixos/tests> + /make-test.nix;

  phpinfo = writeScript "phpinfo.php" ''
    <?php phpinfo(); ?>
  '';

  testPhpDiff = phpVersion: writeScript "test-php-diff.sh" ''
    #!${bash}/bin/bash
    exec &> /tmp/xchg/coverage-data/php-missing-modules.html
    set -e
    cp ${./phpinfo-json.php} /home/u12/${phpVersion}.ru/www/phpinfo-json.php
    diff <(curl --silent http://${phpVersion}.ru/phpinfo-json.php | ${jq}/bin/jq -r '.extensions | sort | .[]') <(${jq}/bin/jq -r '.extensions | sort | .[]' < ${./. + "/${phpVersion}.json"}) | grep '^>'
    if [[ $? -eq 1 ]]; then true; else false; fi
  '';

  wordpressUpgrade = stdenv.mkDerivation rec {
    inherit (lib.traceVal wordpress);
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

  wpInstallScript = php: writeScript "wp-install.php" ''
    #!${php}/bin/php
    <?php

    function get_args()
    {
            $args = array();
            for ($i=1; $i<count($_SERVER['argv']); $i++)
            {
                    $arg = $_SERVER['argv'][$i];
                    if ($arg{0} == '-' && $arg{1} != '-')
                    {
                            for ($j=1; $j < strlen($arg); $j++)
                            {
                                    $key = $arg{$j};
                                    $value = $_SERVER['argv'][$i+1]{0} != '-' ? preg_replace(array('/^["\']/', '/["\']$/'), "", $_SERVER['argv'][++$i]) : true;
                                    $args[$key] = $value;
                            }
                    }
                    else
                            $args[] = $arg;
            }

            return $args;
    }

    // read commandline arguments
    $opt = get_args();

    define( 'WP_INSTALLING', true );

    /** Load WordPress Bootstrap */
    require_once( dirname( dirname( __FILE__ ) ) . '/wp-load.php' );

    /** Load WordPress Administration Upgrade API */
    require_once( dirname( __FILE__ ) . '/includes/upgrade.php' );

    /** Load wpdb */
    require_once(dirname(dirname(__FILE__)) . '/wp-includes/wp-db.php');

    $result = wp_install($opt[0], $opt[1], $opt[2], false, "", $opt[3]);
    ?>
 '';

  wpConfig = writeScript "wp-config.php" ''
    <?php
    /**
     * Основные параметры WordPress.
     *
     * Скрипт для создания wp-config.php использует этот файл в процессе
     * установки. Необязательно использовать веб-интерфейс, можно
     * скопировать файл в "wp-config.php" и заполнить значения вручную.
     *
     * Этот файл содержит следующие параметры:
     *
     * * Настройки MySQL
     * * Секретные ключи
     * * Префикс таблиц базы данных
     * * ABSPATH
     *
     * @link https://codex.wordpress.org/Editing_wp-config.php
     *
     * @package WordPress
     */

    // ** Параметры MySQL: Эту информацию можно получить у вашего хостинг-провайдера ** //
    /** Имя базы данных для WordPress */
    define('DB_NAME', 'wordpress');

    /** Имя пользователя MySQL */
    define('DB_USER', 'wordpress_user');

    /** Пароль к базе данных MySQL */
    define('DB_PASSWORD', 'password123');

    /** Имя сервера MySQL */
    define('DB_HOST', '127.0.0.1');

    /** Кодировка базы данных для создания таблиц. */
    define('DB_CHARSET', 'utf8');

    /** Схема сопоставления. Не меняйте, если не уверены. */
    define('DB_COLLATE', "");

    /**#@+
     * Уникальные ключи и соли для аутентификации.
     *
     * Смените значение каждой константы на уникальную фразу.
     * Можно сгенерировать их с помощью {@link https://api.wordpress.org/secret-key/1.1/salt/ сервиса ключей на WordPress.org}
     * Можно изменить их, чтобы сделать существующие файлы cookies недействительными. Пользователям потребуется авторизоваться снова.
     *
     * @since 2.6.0
     */
    define('AUTH_KEY',         'впишите сюда уникальную фразу');
    define('SECURE_AUTH_KEY',  'впишите сюда уникальную фразу');
    define('LOGGED_IN_KEY',    'впишите сюда уникальную фразу');
    define('NONCE_KEY',        'впишите сюда уникальную фразу');
    define('AUTH_SALT',        'впишите сюда уникальную фразу');
    define('SECURE_AUTH_SALT', 'впишите сюда уникальную фразу');
    define('LOGGED_IN_SALT',   'впишите сюда уникальную фразу');
    define('NONCE_SALT',       'впишите сюда уникальную фразу');

    /**#@-*/

    /**
     * Префикс таблиц в базе данных WordPress.
     *
     * Можно установить несколько сайтов в одну базу данных, если использовать
     * разные префиксы. Пожалуйста, указывайте только цифры, буквы и знак подчеркивания.
     */
    $table_prefix  = 'wp_';

    /**
     * Для разработчиков: Режим отладки WordPress.
     *
     * Измените это значение на true, чтобы включить отображение уведомлений при разработке.
     * Разработчикам плагинов и тем настоятельно рекомендуется использовать WP_DEBUG
     * в своём рабочем окружении.
     *
     * Информацию о других отладочных константах можно найти в Кодексе.
     *
     * @link https://codex.wordpress.org/Debugging_in_WordPress
     */
    define('WP_DEBUG', false);

    /* Это всё, дальше не редактируем. Успехов! */

    /** Абсолютный путь к директории WordPress. */
    if ( !defined('ABSPATH') )
            define('ABSPATH', dirname(__FILE__) . '/');

    /** Инициализирует переменные WordPress и подключает файлы. */
    require_once(ABSPATH . 'wp-settings.php');
  '';

  # Return a PHP version from ‘php’ attribute.
  php2version = php: "php" +
                    lib.versions.major php.version +
                    lib.versions.minor php.version;

  wordpressScript = php:
    let
      phpVersion = php2version php;
    in
      writeScript "wordpress.sh" ''
        #!${bash}/bin/bash
        # Install and test WordPress.
        exec &> /tmp/xchg/coverage-data/wordpress.log

        set -e -x

        tar -v -C /home/u12/${phpVersion}.ru/www --strip-components=1 -xf ${wordpress.src}

        cp -v ${wordpressUpgrade}/share/wordpress/wp-admin/includes/upgrade.php \
          /home/u12/${phpVersion}.ru/www/wp-admin/includes/upgrade.php

        cp -v ${wpConfig} /home/u12/${phpVersion}.ru/www/wp-config.php

        chown u12: -R /home/u12

        cp -v ${wpInstallScript php} \
          /home/u12/${phpVersion}.ru/www/wp-admin/my-install
        cd /home/u12/${phpVersion}.ru/www/wp-admin
        chmod a+x my-install
        ./my-install Congratulations wordpress root@localhost secret
        cd -

        curl --silent http://${phpVersion}.ru/ | grep Congratulations
      '';

    wrkScript = writeScript "wrk.sh" ''
      #!${bash}/bin/bash
      # Run wrk test.
      exec &> /tmp/xchg/coverage-data/wrk.log
      set -e -x
      ${wrk2}/bin/wrk2 -t2 -c100 -d30s -R2000 http://${phpVersion}.ru/
    '';

    phpVersion = php2version php;
    domain = phpVersion + ".ru";

in

import maketest ({ pkgs, lib, ... }: {
  name = "apache2-" + phpVersion + "-default" + (if private then "-private" else "");
  nodes = {
    docker = { pkgs, ... }:
      {
        virtualisation =
          {
            memorySize = 4 * 1024;
            diskSize = 4 * 1024;
            docker.enable = true;
            dockerPreloader = {
              images = [ image ];
              qcowSize = 4 * 1024;
            };
            # DEBUG:
            # qemu.networkingOptions = [
            #   "-net nic,model=virtio" "-net user,hostfwd=tcp::2222-:22"
            # ];
          };

        networking.extraHosts = "127.0.0.1 ${domain}";
        users.users.u12 =
          {
            isNormalUser = true;
            description = "Test user";
            password = "foobar";
          };

        # DEBUG:
        # services.openssh.enable = true;
        # services.openssh.permitRootLogin = "without-password";

        boot.initrd.postMountCommands = ''
                for dir in /apache2-${phpVersion}-default /opcache /home \
                           /opt/postfix/spool/public /opt/postfix/spool/maildrop \
                           /opt/postfix/lib; do
                    mkdir -p /mnt-root$dir
                done

                mkdir /mnt-root/apache2-${phpVersion}-default/sites-enabled

                cat <<EOF > /mnt-root/apache2-${phpVersion}-default/sites-enabled/5d41c60519f4690001176012.conf
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
                    ${(if private then "" else "MaxClientsVHost 20\nAssignUserID \"#4165\" \"#4165\"")}
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

        # From official nixpkgs Git repository:
        # nixos/modules/virtualisation/docker-containers.nix
        docker-containers.php = {
          image = "docker-registry.intr/webservices/apache2-${phpVersion}" + (if private then "-private" else "");
          extraDockerOptions = ["--network=host"
                                "--cap-add" "SYS_ADMIN"
                                "--mount" "readonly,source=/etc/passwd,target=/etc/passwd,type=bind"
                                "--mount" "readonly,source=/etc/group,target=/etc/group,type=bind"
                                "--mount" "target=/opcache,type=tmpfs"
                                "--mount" "source=/home,target=/home,type=bind"
                                "--mount" "source=/opt/postfix/spool/maildrop,target=/var/spool/postfix/maildrop,type=bind"
                                "--mount" "source=/opt/postfix/spool/public,target=/var/spool/postfix/public,type=bind"
                                "--mount" "source=/opt/postfix/lib,target=/var/lib/postfix,type=bind"
                                "--mount" "target=/run,type=tmpfs"
                                "--mount" "target=/tmp,type=tmpfs"
                                "--mount"]
          # XXX:
          ++ lib.optional true (lib.concatStrings ["readonly,source=/apache2-${phpVersion}-default,target=/read,type=bind"]);

          # TODO: Use dockerArgHints.volumes
          # map (x:
          #       (array: lib.concatStringsSep ":" (lib.remove true array)) (lib.mapAttrsToList (name: value: value) x))
          #       dockerArgs.volumes;

          environment = {
            HTTPD_PORT = "80";
            PHP_INI_SCAN_DIR = ":${rootfs}/etc/phpsec/default";
          };
        };
      };
  };

  testScript = [
    ''
          startAll;

          print "Start services.\n";
          $docker->waitForUnit("docker-php");

          $docker->sleep(10);
          $docker->succeed("docker exec docker-php.service sh -c 'type optipng'");
          $docker->succeed("docker exec docker-php.service sh -c 'type jpegtran'");
          $docker->succeed("docker exec docker-php.service sh -c 'type gifsicle'");

          $docker->waitForUnit("mysql");

          print "Get phpinfo.\n";
          $docker->execute("cp -v ${phpinfo} /home/u12/${domain}/www/phpinfo.php");
          $docker->succeed("curl --connect-timeout 30 -f --silent --output /tmp/xchg/coverage-data/phpinfo.html http://${domain}/phpinfo.php");

          print "Get server-status.\n";
          $docker->succeed("curl --connect-timeout 30 -f --silent --output /tmp/xchg/coverage-data/server-status.html http://127.0.0.1/server-status");

          print "Get PHP diff.\n";
          $docker->execute("${testPhpDiff phpVersion}");

          print "Run Bitrix test.\n";
          $docker->succeed("cp -v ${./bitrix_server_test.php} /home/u12/${domain}/www/bitrix_server_test.php");
          $docker->succeed("curl --connect-timeout 30 -f --silent --output /tmp/xchg/coverage-data/bitrix_server_test.html http://${domain}/bitrix_server_test.php");
        '']

  ++ optional (versionAtLeast php.version "7") ''
           $docker->execute("${wordpressScript php}");
           $docker->execute("${wrkScript}");
        ''

  ++
  [''
     print "Shutdown virtual machine.\n";
     $docker->shutdown;
   ''];
})
