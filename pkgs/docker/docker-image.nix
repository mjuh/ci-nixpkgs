{ lib
, pkgs
, mjHttpErrorPages
, CGI
, DBDmysql
, DBI
, DigestPerlMD5
, DigestSHA1
, FileBOM
, FilePath
, GD
, HashDiff
, JSONXS
, LWP
, LWPProtocolHttps
, ListMoreUtilsXS
, LocaleGettext
, Mojolicious
, POSIXstrftimeCompiler
, PerlMagick
, TextTruncate
, TimeLocal
, apacheHttpd
, apacheHttpdmpmITK
, commonsense
, connectorc
, coreutils
, curl
, dash
, execline
, findutils
, gcc-unwrapped
, glibcLocales
, ioncube
, libintl_perl
, libjpeg130
, libjpegv6b
, libnet
, libxml_perl
, mime-types
, mjPerlPackages
, mjperl5Packages
, mjperl5lib
, pcre831
, perl
, php
, phpPackages
, postfix
, s6
, s6-linux-utils
, s6-portable-utils
, tzdata
, zendguard
, zendoptimizer
}:

with lib;

let
  inherit (lib) concatMapStringsSep firstNChars flattenSet dockerRunCmd mkRootfs;

  locale = glibcLocales.override {
    allLocales = false;
    locales = ["en_US.UTF-8/UTF-8"];
  };

  sh = dash.overrideAttrs (_: rec {
    postInstall = ''
    ln -s dash "$out/bin/sh"
  '';
  });

  phpDockerArgHints = php:
    {
      init = false;
      read_only = true;
      network = "host";
      environment = {
        HTTPD_PORT = "$SOCKET_HTTP_PORT";
        PHP_SECURITY = "/etc/phpsec/$SECURITY_LEVEL";
      };

      tmpfs = [
        "/tmp:mode=1777"
        "/run/bin:exec,suid"
      ]
      ++ optional (versionOlder php.version "5.5")
        "/run/php${lib.versions.major php.version +
                   lib.versions.minor php.version}.d:mode=644";

      ulimits = [
        { name = "stack"; hard = -1; soft = -1; }
      ];
      security_opt = [ "apparmor:unconfined" ];
      cap_add = [ "SYS_ADMIN" ];
      volumes = [
        ({ type = "bind";
           source = "$SITES_CONF_PATH" ;
           target = "/read/sites-enabled";
           read_only = true;
         })
        ({ type = "bind";
           source = "/etc/passwd" ;
           target = "/etc/passwd";
           read_only = true;
         })
        ({ type = "bind";
           source = "/etc/group" ;
           target = "/etc/group";
           read_only = true;
         })
        ({ type = "bind";
           source = "/opt/postfix/spool/maildrop";
           target = "/var/spool/postfix/maildrop";
         })
        ({ type = "bind";
           source = "/opt/postfix/spool/public";
           target = "/var/spool/postfix/public";
         })
        ({ type = "bind";
           source = "/opt/postfix/lib";
           target = "/var/lib/postfix";
         })
        ({ type = "bind"; source = "/opcache"; target = "/opcache";})
        ({ type = "bind"; source = "/home"; target = "/home";})
        ({ type = "tmpfs"; target = "/run";})];
    };

  php4DockerArgHints = phpDockerArgHints php.php4;
  php52DockerArgHints = phpDockerArgHints php.php52;
  php53DockerArgHints = phpDockerArgHints php.php53;
  php54DockerArgHints = phpDockerArgHints php.php54;
  php55DockerArgHints = phpDockerArgHints php.php55;
  php56DockerArgHints = phpDockerArgHints php.php56;
  php70DockerArgHints = phpDockerArgHints php.php70;
  php71DockerArgHints = phpDockerArgHints php.php71;
  php72DockerArgHints = phpDockerArgHints php.php72;
  php73DockerArgHints = phpDockerArgHints php.php73;

  php72-rootfs = mkRootfs {
    name = "apache2-php72-rootfs";
    src = ./php72-rootfs;
    inherit curl coreutils findutils apacheHttpdmpmITK apacheHttpd
      mjHttpErrorPages postfix s6 execline;
    php72 = php.php72;
    mjperl5Packages = mjperl5lib;
    ioncube = ioncube.v72;
    s6PortableUtils = s6-portable-utils;
    s6LinuxUtils = s6-linux-utils;
    mimeTypes = mime-types;
    libstdcxx = gcc-unwrapped.lib;
  };


  php71-rootfs = mkRootfs {
    name = "apache2-php71-rootfs";
    src = ./php71-rootfs;
    inherit curl coreutils findutils apacheHttpdmpmITK apacheHttpd
      mjHttpErrorPages postfix s6 execline;
    php71 = php.php71;
    mjperl5Packages = mjperl5lib;
    ioncube = ioncube.v71;
    s6PortableUtils = s6-portable-utils;
    s6LinuxUtils = s6-linux-utils;
    mimeTypes = mime-types;
    libstdcxx = gcc-unwrapped.lib;
  };

  php70-rootfs = mkRootfs {
    name = "apache2-php70-rootfs";
    src = ./php70-rootfs;
    inherit curl coreutils findutils apacheHttpdmpmITK apacheHttpd
      mjHttpErrorPages postfix s6 execline;
    php70 = php.php70;
    mjperl5Packages = mjperl5lib;
    ioncube = ioncube.v70;
    s6PortableUtils = s6-portable-utils;
    s6LinuxUtils = s6-linux-utils;
    mimeTypes = mime-types;
    libstdcxx = gcc-unwrapped.lib;
  };

  php56-rootfs = mkRootfs {
    name = "apache2-php56-rootfs";
    src = ./php56-rootfs;
    inherit curl coreutils findutils apacheHttpdmpmITK apacheHttpd
      mjHttpErrorPages postfix s6 execline;
    mjperl5Packages = mjperl5lib;
    php56 = php.php56;
    zendguard = zendguard.loader-php56;
    ioncube = ioncube.v56;
    s6PortableUtils = s6-portable-utils;
    s6LinuxUtils = s6-linux-utils;
    mimeTypes = mime-types;
    libstdcxx = gcc-unwrapped.lib;
  };

  php55-rootfs = mkRootfs {
    name = "apache2-php55-rootfs";
    src = ./php55-rootfs;
    inherit curl coreutils findutils apacheHttpdmpmITK apacheHttpd
      mjHttpErrorPages postfix s6 execline;
    php55 = php.php55;
    mjperl5Packages = mjperl5lib;
    ioncube = ioncube.v55;
    s6PortableUtils = s6-portable-utils;
    s6LinuxUtils = s6-linux-utils;
    mimeTypes = mime-types;
    libstdcxx = gcc-unwrapped.lib;
  };

  php54-rootfs = mkRootfs {
    name = "apache2-php54-rootfs";
    src = ./php54-rootfs;
    inherit curl coreutils findutils apacheHttpdmpmITK apacheHttpd
      mjHttpErrorPages postfix s6 execline;
    php54 = php.php54;
    mjperl5Packages = mjperl5lib;
    ioncube = ioncube.v54;
    s6PortableUtils = s6-portable-utils;
    s6LinuxUtils = s6-linux-utils;
    mimeTypes = mime-types;
    libstdcxx = gcc-unwrapped.lib;
  };

  php53-rootfs = mkRootfs {
    name = "apache2-php53-rootfs";
    src = ./php53-rootfs;
    zendguard = zendguard.loader-php53;
    inherit curl coreutils findutils apacheHttpdmpmITK apacheHttpd
      mjHttpErrorPages postfix s6 execline;
    php53 = php.php53;
    mjperl5Packages = mjperl5lib;
    ioncube = ioncube.v53;
    s6PortableUtils = s6-portable-utils;
    s6LinuxUtils = s6-linux-utils;
    mimeTypes = mime-types;
    libstdcxx = gcc-unwrapped.lib;
  };

  php52-rootfs = mkRootfs {
    name = "apache2-php52-rootfs";
    src = ./php52-rootfs;
    inherit curl coreutils findutils apacheHttpdmpmITK apacheHttpd
      mjHttpErrorPages postfix s6 execline connectorc;
    php52 = php.php52;
    mjperl5Packages = mjperl5lib;
    ioncube = ioncube.v52;
    zendoptimizer = zendoptimizer.v52;
    zendopcache = phpPackages.php52Packages.zendopcache;
    s6PortableUtils = s6-portable-utils;
    s6LinuxUtils = s6-linux-utils;
    mimeTypes = mime-types;
    libstdcxx = gcc-unwrapped.lib;
  };

  php73-rootfs = mkRootfs {
    name = "apache2-php73-rootfs";
    src = ./php73-rootfs;
    inherit curl coreutils findutils apacheHttpdmpmITK apacheHttpd
      mjHttpErrorPages postfix s6 execline;
    php73 = php.php73;
    mjperl5Packages = mjperl5lib;
    ioncube = ioncube.v73;
    s6PortableUtils = s6-portable-utils;
    s6LinuxUtils = s6-linux-utils;
    mimeTypes = mime-types;
    libstdcxx = gcc-unwrapped.lib;
  };

in

{
  php52-image = pkgs.dockerTools.buildLayeredImage rec {
    maxLayers = 124;
    name = "docker-registry.intr/webservices/apache2-php52";
    tag = "latest";
    contents = [
      php52-rootfs
      tzdata
      locale
      postfix
      sh
      coreutils
      perl
    ] ++ collect isDerivation phpPackages.php52Packages;
    config = {
      Entrypoint = [ "${php52-rootfs}/init" ];
      Env = [
        "TZ=Europe/Moscow"
        "TZDIR=${tzdata}/share/zoneinfo"
        "LOCALE_ARCHIVE_2_27=${locale}/lib/locale/locale-archive"
        "LC_ALL=en_US.UTF-8"
      ];
      Labels = flattenSet rec {
        ru.majordomo.docker.arg-hints-json = builtins.toJSON php52DockerArgHints;
        ru.majordomo.docker.cmd = dockerRunCmd php52DockerArgHints "${name}:${tag}";
        ru.majordomo.docker.exec.reload-cmd = "${apacheHttpd}/bin/httpd -d ${php52-rootfs}/etc/httpd -k graceful";
      };
    };
  };

  php53-image = pkgs.dockerTools.buildLayeredImage rec {
    maxLayers = 124;
    name = "docker-registry.intr/webservices/apache2-php53";
    tag = "latest";
    contents = [
      php53-rootfs
      tzdata
      locale
      postfix
      sh
      coreutils
      perl
    ] ++ collect isDerivation phpPackages.php53Packages;
    config = {
      Entrypoint = [ "${php53-rootfs}/init" ];
      Env = [
        "TZ=Europe/Moscow"
        "TZDIR=${tzdata}/share/zoneinfo"
        "LOCALE_ARCHIVE_2_27=${locale}/lib/locale/locale-archive"
        "LC_ALL=en_US.UTF-8"
      ];
      Labels = flattenSet rec {
        ru.majordomo.docker.arg-hints-json = builtins.toJSON php53DockerArgHints;
        ru.majordomo.docker.cmd = dockerRunCmd php53DockerArgHints "${name}:${tag}";
        ru.majordomo.docker.exec.reload-cmd = "${apacheHttpd}/bin/httpd -d ${php53-rootfs}/etc/httpd -k graceful";
      };
    };
  };

  php54-image = pkgs.dockerTools.buildLayeredImage rec {
    maxLayers = 124;
    name = "docker-registry.intr/webservices/apache2-php54";
    tag = "latest";
    contents = [
      php54-rootfs
      tzdata
      locale
      postfix
      sh
      coreutils
      perl
    ] ++ collect isDerivation phpPackages.php54Packages;
    config = {
      Entrypoint = [ "${php54-rootfs}/init" ];
      Env = [
        "TZ=Europe/Moscow"
        "TZDIR=${tzdata}/share/zoneinfo"
        "LOCALE_ARCHIVE_2_27=${locale}/lib/locale/locale-archive"
        "LC_ALL=en_US.UTF-8"
      ];
      Labels = flattenSet rec {
        ru.majordomo.docker.arg-hints-json = builtins.toJSON php54DockerArgHints;
        ru.majordomo.docker.cmd = dockerRunCmd php54DockerArgHints "${name}:${tag}";
        ru.majordomo.docker.exec.reload-cmd = "${apacheHttpd}/bin/httpd -d ${php54-rootfs}/etc/httpd -k graceful";
      };
    };
  };

  php55-image = pkgs.dockerTools.buildLayeredImage rec {
    maxLayers = 124;
    name = "docker-registry.intr/webservices/apache2-php55";
    tag = "latest";
    contents = [
      php55-rootfs
      tzdata
      locale
      postfix
      sh
      coreutils
      perl
    ] ++ collect isDerivation phpPackages.php55Packages;
    config = {
      Entrypoint = [ "${php55-rootfs}/init" ];
      Env = [
        "TZ=Europe/Moscow"
        "TZDIR=${tzdata}/share/zoneinfo"
        "LOCALE_ARCHIVE_2_27=${locale}/lib/locale/locale-archive"
        "LC_ALL=en_US.UTF-8"
      ];
      Labels = flattenSet rec {
        ru.majordomo.docker.arg-hints-json = builtins.toJSON php55DockerArgHints;
        ru.majordomo.docker.cmd = dockerRunCmd php55DockerArgHints "${name}:${tag}";
        ru.majordomo.docker.exec.reload-cmd = "${apacheHttpd}/bin/httpd -d ${php55-rootfs}/etc/httpd -k graceful";
      };
    };
  };

  php56-image = pkgs.dockerTools.buildLayeredImage rec {
    maxLayers = 124;
    name = "docker-registry.intr/webservices/apache2-php56";
    tag = "latest";
    contents = [
      php56-rootfs
      tzdata
      locale
      postfix
      sh
      coreutils
    ]
    ++ collect isDerivation mjperl5Packages
    ++ collect isDerivation phpPackages.php56Packages;
    config = {
      Entrypoint = [ "${php56-rootfs}/init" ];
      Env = [
        "TZ=Europe/Moscow"
        "TZDIR=${tzdata}/share/zoneinfo"
        "LOCALE_ARCHIVE_2_27=${locale}/lib/locale/locale-archive"
        "LC_ALL=en_US.UTF-8"
      ];
      Labels = flattenSet rec {
        ru.majordomo.docker.arg-hints-json = builtins.toJSON php56DockerArgHints;
        ru.majordomo.docker.cmd = dockerRunCmd php56DockerArgHints "${name}:${tag}";
        ru.majordomo.docker.exec.reload-cmd = "${apacheHttpd}/bin/httpd -d ${php56-rootfs}/etc/httpd -k graceful";
      };
    };
  };

  php70-image = pkgs.dockerTools.buildLayeredImage rec {
    maxLayers = 124;
    name = "docker-registry.intr/webservices/apache2-php70";
    tag = "latest";
    contents = [
      php70-rootfs
      tzdata
      locale
      postfix
      sh
      coreutils
    ]
    ++ collect isDerivation mjperl5Packages
    ++ collect isDerivation phpPackages.php70Packages;
    config = {
      Entrypoint = [ "${php70-rootfs}/init" ];
      Env = [
        "TZ=Europe/Moscow"
        "TZDIR=${tzdata}/share/zoneinfo"
        "LOCALE_ARCHIVE_2_27=${locale}/lib/locale/locale-archive"
        "LC_ALL=en_US.UTF-8"
      ];
      Labels = flattenSet rec {
        ru.majordomo.docker.arg-hints-json = builtins.toJSON php70DockerArgHints;
        ru.majordomo.docker.cmd = dockerRunCmd php70DockerArgHints "${name}:${tag}";
        ru.majordomo.docker.exec.reload-cmd = "${apacheHttpd}/bin/httpd -d ${php70-rootfs}/etc/httpd -k graceful";
      };
    };
  };

  php71-image = pkgs.dockerTools.buildLayeredImage rec {
    maxLayers = 124;
    name = "docker-registry.intr/webservices/apache2-php71";
    tag = "latest";
    contents = [
      php71-rootfs
      tzdata
      locale
      postfix
      sh
      coreutils
      perl
    ] ++ collect isDerivation phpPackages.php71Packages;
    config = {
      Entrypoint = [ "${php71-rootfs}/init" ];
      Env = [
        "TZ=Europe/Moscow"
        "TZDIR=${tzdata}/share/zoneinfo"
        "LOCALE_ARCHIVE_2_27=${locale}/lib/locale/locale-archive"
        "LC_ALL=en_US.UTF-8"
      ];
      Labels = flattenSet rec {
        ru.majordomo.docker.arg-hints-json = builtins.toJSON php71DockerArgHints;
        ru.majordomo.docker.cmd = dockerRunCmd php71DockerArgHints "${name}:${tag}";
        ru.majordomo.docker.exec.reload-cmd = "${apacheHttpd}/bin/httpd -d ${php71-rootfs}/etc/httpd -k graceful";
      };
    };
  };

  php72-image = pkgs.dockerTools.buildLayeredImage rec {
    maxLayers = 124;
    name = "docker-registry.intr/webservices/apache2-php72";
    tag = "latest";
    contents = [
      php72-rootfs
      tzdata
      locale
      postfix
      sh
      coreutils
    ] ++ collect isDerivation phpPackages.php72Packages;
    config = {
      Entrypoint = [ "${php72-rootfs}/init" ];
      Env = [
        "TZ=Europe/Moscow"
        "TZDIR=${tzdata}/share/zoneinfo"
        "LOCALE_ARCHIVE_2_27=${locale}/lib/locale/locale-archive"
        "LC_ALL=en_US.UTF-8"
      ];
      Labels = flattenSet rec {
        ru.majordomo.docker.arg-hints-json = builtins.toJSON php72DockerArgHints;
        ru.majordomo.docker.cmd = dockerRunCmd php72DockerArgHints "${name}:${tag}";
        ru.majordomo.docker.exec.reload-cmd = "${apacheHttpd}/bin/httpd -d ${php72-rootfs}/etc/httpd -k graceful";
      };
    };
  };

  php73-image = pkgs.dockerTools.buildLayeredImage rec {
    maxLayers = 124;
    name = "docker-registry.intr/webservices/apache2-php73";
    tag = "latest";
    contents = [
      php73-rootfs
      tzdata
      locale
      postfix
      sh
      coreutils
    ]
    ++ collect isDerivation mjperl5Packages
    ++ collect isDerivation phpPackages.php73Packages;
    config = {
      Entrypoint = [ "${php73-rootfs}/init" ];
      Env = [
        "TZ=Europe/Moscow"
        "TZDIR=${tzdata}/share/zoneinfo"
        "LOCALE_ARCHIVE_2_27=${locale}/lib/locale/locale-archive"
        "LC_ALL=en_US.UTF-8"
      ];
      Labels = flattenSet rec {
        ru.majordomo.docker.arg-hints-json = builtins.toJSON php73DockerArgHints;
        ru.majordomo.docker.cmd = dockerRunCmd php73DockerArgHints "${name}:${tag}";
        ru.majordomo.docker.exec.reload-cmd = "${apacheHttpd}/bin/httpd -d ${php73-rootfs}/etc/httpd -k graceful";
      };
    };
  };
}
