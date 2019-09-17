{ lib
, php
, wordpress
, image
, phpinfoCompare
}:

with lib;

# Test Docker containers as systemd units

with import <nixpkgs> {};

let
  pkgs = <nixpkgs>;
  maketest = <nixpkgs/nixos/tests> + /make-test.nix;

  testPhpModulesPresent = myphp: writeScript "test-php-modules-present.sh" ''
    #!/bin/sh
    exec &>/tmp/xchg/coverage-data/php-missing-modules.txt
    set -e -x
    for module in NTS bcmath bz2 calendar Core ctype curl date dba dom \
                  exif fileinfo filter ftp gd gettext gmp hash iconv \
                  imagick imap intl ionCube Loader json libxml mbstring \
                  mysqli mysqlnd openssl pcre PDO pdo_mysql pdo_sqlite \
                  pgsql Phar posix redis Reflection rrd session SimpleXML \
                  soap sockets SPL sqlite3 standard sysvsem sysvshm tidy \
                  timezonedb tokenizer xml xmlreader xmlrpc xmlwriter xsl \
                  Zend OPcache zip zlib 'ionCube Loader' OPcache; do
        curl -s http://${myphp}/phpinfo.php \
            | grep --max-count=1 "$module" \
            || echo "@ $module not found" && false
    done
  '';

  testPhpDiff = myphp: writeScript "test-php-diff.sh" ''
    #!/bin/sh
    exec &>/tmp/xchg/coverage-data/php-diff-${myphp}.log
    set -e -x
    diff <(curl --silent http://${myphp}.ru/phpinfo.php | ${jq}/bin/jq -r '.extensions | sort | .[]') \
         <(${jq}/bin/jq -r '.extensions | sort | .[]' < ${./php52.json}) | grep '^>'; if [[ $? -eq 1 ]]; then true; else false; fi
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
    #!/${php}/bin/php
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

  phpVersion = php: "php" +
                    lib.versions.major php.version +
                    lib.versions.minor php.version;

  generic = { php, image, rootfs }:
    let
      myphp = phpVersion php;
    in
    import maketest ({ pkgs, lib, ... }: {
      name = "apache2-" + myphp + "-default";
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

            networking.extraHosts = "127.0.0.1 ${myphp}.ru";
            users.users.u12 =
              {
                isNormalUser = true;
                description = "Test user";
                password = "foobar";
              };

            # DEBUG:
            # services.openssh.enable = true;

            boot.initrd.postMountCommands = concatStrings ([
              ''
                for dir in apache2-${myphp}-default opcache home; do mkdir /mnt-root/$dir; done

                mkdir /mnt-root/apache2-${myphp}-default/sites-enabled

                cat <<EOF > /mnt-root/apache2-${myphp}-default/sites-enabled/5d41c60519f4690001176012.conf
                <VirtualHost 127.0.0.1:80>
                    ServerName ${myphp}.ru
                    ServerAlias www.${myphp}.ru
                    ScriptAlias /cgi-bin /home/u12/${myphp}.ru/www/cgi-bin
                    DocumentRoot /home/u12/${myphp}.ru/www
                    <Directory /home/u12/${myphp}.ru/www>
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
                    CustomLog /home/u12/logs/www.${myphp}.ru-access.log common-time
                    ErrorLog /home/u12/logs/www.${myphp}.ru-error_log
                    </IfFile>
                    MaxClientsVHost 20
                    AssignUserID "#4165" "#4165"
                </VirtualHost>
                EOF

                mkdir -p /mnt-root/home/u12/${myphp}.ru/www

                cp -v ${./bitrix_server_test.php} /mnt-root/home/u12/${myphp}.ru/www/bitrix_server_test.php
              ''
            ]

            ++ optional (builtins.pathExists ./web37-phpinfo-php70.html)
              ''
                cp -v ${./web37-phpinfo-php70.html} /mnt-root/home/u12/${myphp}.ru/www/phpinfo.php
              ''

            ++
              [
                ''
                  for dir in /mnt-root/opt/postfix/spool/public /mnt-root/opt/postfix/spool/maildrop /mnt-root/opt/postfix/lib; do mkdir -p $dir ; done

                  tar -v -C /mnt-root/home/u12/${myphp}.ru/www --strip-components=1 -xf ${wordpress.src}
                  cp -v ${wordpressUpgrade}/share/wordpress/wp-admin/includes/upgrade.php /mnt-root/home/u12/${myphp}.ru/www/wp-admin/includes/upgrade.php
                  cp -v ${wpInstallScript php} /mnt-root/home/u12/${myphp}.ru/www/wp-admin/my-install.php
                  cp -v ${wpConfig} /mnt-root/home/u12/${myphp}.ru/www/wp-config.php
                  chmod a+x /mnt-root/home/u12/${myphp}.ru/www/wp-admin/my-install.php
                  chown u12: -R /mnt-root/home/u12
                ''
              ]);

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
              image = "docker-registry.intr/webservices/apache2-${myphp}";
              extraDockerOptions = ["--network=host"
                                    "--cap-add" "SYS_ADMIN"
                                    "--mount" "readonly,source=/etc/passwd,target=/etc/passwd,type=bind"
                                    "--mount" "readonly,source=/etc/group,target=/etc/group,type=bind"
                                    "--mount" "source=/opcache,target=/opcache,type=bind"
                                    "--mount" "source=/home,target=/home,type=bind"
                                    "--mount" "source=/opt/postfix/spool/maildrop,target=/var/spool/postfix/maildrop,type=bind"
                                    "--mount" "source=/opt/postfix/spool/public,target=/var/spool/postfix/public,type=bind"
                                    "--mount" "source=/opt/postfix/lib,target=/var/lib/postfix,type=bind"
                                    "--mount" "target=/run,type=tmpfs"
                                    "--mount" "target=/tmp,type=tmpfs"
                                    "--mount"] 
              # XXX:
              ++ lib.optional true (lib.concatStrings ["readonly,source=/apache2-${myphp}-default,target=/read,type=bind"]);

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

          $docker->waitForUnit("docker-php");
          $docker->waitForUnit("mysql");

          my $log = $docker->execute("${testPhpDiff myphp}");

          $docker->waitUntilSucceeds("curl --silent --output /tmp/xchg/coverage-data/phpinfo-${myphp}.html --head --header \"Host: ${myphp}.ru\" http://127.0.0.1/phpinfo.php") =~ /200 OK/;
          $docker->execute("${php}/bin/php ${phpinfoCompare} http://${myphp}.ru/phpinfo.php http://127.0.0.1/phpinfo.php > /tmp/xchg/coverage-data/diff-${myphp}.html");
        '']

        ++ optional (versionAtLeast php.version "7")
        ''
          $docker->succeed("cd /home/u12/${myphp}.ru/www/wp-admin; ./my-install.php 'Congratulations' wordpress root\@localhost secret");

          $docker->succeed("mysql wordpress -e 'update wp_options set option_value=\"http://${myphp}.ru\" where  option_name=\"siteurl\";'");
          $docker->succeed("mysql wordpress -e 'update wp_options set option_value=\"http://${myphp}.ru\" where  option_name=\"home\";'");

          $docker->waitUntilSucceeds("curl --silent http://${myphp}.ru/ | grep Congratulations");

          $docker->waitUntilSucceeds("curl --output /tmp/xchg/coverage-data/bitrix_server_test_${myphp}.html http://${myphp}.ru/bitrix_server_test.php");
        ''

        ++
        [''
           $docker->shutdown;
         ''];
    });

in

{
  php52 = generic { 
    php = php.php52;
    image = image.php52-image;
    rootfs = ./php52-rootfs;
  };
  php53 = generic { 
    php = php.php53;
    image = image.php53-image;
    rootfs = ./php53-rootfs;
  };
  php54 = generic { 
    php = php.php54;
    image = image.php54-image;
    rootfs = ./php54-rootfs;
  };
  php55 = generic { 
    php = php.php55;
    image = image.php55-image;
    rootfs = ./php55-rootfs;
  };
  php56 = generic { 
    php = php.php56;
    image = image.php56-image;
    rootfs = ./php56-rootfs;
  };
  php70 = generic { 
    php = php.php70;
    image = image.php70-image;
    rootfs = ./php70-rootfs;
  };
  php71 = generic { 
    php = php.php71;
    image = image.php71-image;
    rootfs = ./php71-rootfs;
  };
  php72 = generic { 
    php = php.php72;
    image = image.php72-image;
    rootfs = ./php72-rootfs;
  };
  php73 = generic { 
    php = php.php73;
    image = image.php73-image;
    rootfs = ./php73-rootfs;
  };
}
