{ pkgs, lib ? pkgs.lib, php
, wordpress ? (pkgs.callPackage ../../pkgs/wordpress { }) }:

with lib;
with pkgs;

let
  phpVersion = "php" + lib.versions.major php.version
    + lib.versions.minor php.version;
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

  wpInstallScript = php:
    writeScript "wp-install.php" ''
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

  cp -v ${wpInstallScript php} \
    /home/u12/${phpVersion}.ru/www/wp-admin/my-install
  cd /home/u12/${phpVersion}.ru/www/wp-admin
  chmod a+x my-install
  ./my-install Congratulations wordpress root@localhost secret
  cd -

  mysql -e "UPDATE wp_options SET option_value = 'php73.ru' WHERE option_name = 'home' OR option_name = 'siteurl';" wordpress

  curl --silent http://${phpVersion}.ru/ | grep Congratulations
''
