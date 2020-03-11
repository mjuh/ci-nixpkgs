{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, php, home ? true, init ? false
, read_only ? true, network ? "host", security_opt ? [ "apparmor:unconfined" ]
, cap_add ? [ "SYS_ADMIN" ], extraVolumes ? [] }:

with lib;

{
  inherit init read_only network security_opt cap_add;
  environment = if (versionAtLeast php.version "5.5") then {
    HTTPD_PORT = "$SOCKET_HTTP_PORT";
    PHP_SECURITY = "/etc/phpsec/$SECURITY_LEVEL";
    PHP_INI_SCAN_DIR = ":/etc/phpsec/$SECURITY_LEVEL";
  } else {
    HTTPD_PORT = "$SOCKET_HTTP_PORT";
    PHP_SECURITY = "/etc/phpsec/$SECURITY_LEVEL";
  };

  tmpfs = [ "/tmp:mode=1777" "/run/bin:exec,suid" ]
    ++ optional (versionOlder php.version "5.5") "/run/php${
      versions.major php.version + versions.minor php.version
    }.d:mode=644";

  ulimits = [{
    name = "stack";
    hard = -1;
    soft = -1;
  }];
  volumes = [
    ({
      type = "bind";
      source = "/etc/ssl";
      target = "/etc/ssl";
      read_only = true;
    })
    ({
      type = "bind";
      source = "$SITES_CONF_PATH";
      target = "/read/sites-enabled";
      read_only = true;
    })
    ({
      type = "bind";
      source = "/opt/etc";
      target = "/opt/etc";
      read_only = true;
    })
    ({
      type = "bind";
      source = "/opt/postfix/spool/maildrop";
      target = "/var/spool/postfix/maildrop";
    })
    ({
      type = "bind";
      source = "/opt/postfix/spool/public";
      target = "/var/spool/postfix/public";
    })
    ({
      type = "bind";
      source = "/opt/postfix/lib";
      target = "/var/lib/postfix";
    })
    ({
      type = "bind";
      source = "/opcache";
      target = "/opcache";
    })
    ({
      type = "tmpfs";
      target = "/run";
    })
  ] ++ optional home ({
    type = "bind";
    source = "/home";
    target = "/home";
  }) ++ extraVolumes;
}
