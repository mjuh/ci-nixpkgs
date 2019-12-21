{ pkgs, php }:

with pkgs;

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
''
