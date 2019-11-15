{ pkgs }:

with pkgs.lib;

rec {
  firstNChars = n: str: concatStrings (take n (stringToCharacters str));

  flattenSetSep = sep: set: listToAttrs (collect (x: x ? name) (mapAttrsRecursive (p: v: attrsets.nameValuePair (builtins.concatStringsSep sep p) v) set));

  flattenSet = set: flattenSetSep "." set;

  keyValOrBoolKey = k: v: if isBool v then optionalString v "${k}" else "${k}=${v}";

  setToCommaSep = x: concatStringsSep "," (filter (e: if (e != null && e != "") then true else false) (mapAttrsToList keyValOrBoolKey x));

  setToKeyVal = x: mapAttrsToList (k: v: "${k}=${v}") x;

  dockerMountArg = volume: "--mount " + setToCommaSep (flattenSetSep "-" (mapAttrs' (n: v: nameValuePair (builtins.replaceStrings ["_"] [""] n) v) volume));

  dockerUlimitArg = { name, soft, hard ? soft }: "--ulimit ${name}=${toString soft}:${toString hard}";

  dockerRunCmd = {
      init ? false,
      read_only ? false,
      network ? null,
      volumes ? null,
      environment ? null,
      ulimits ? null,
      cap_add ? null,
      cap_drop ? null,
      security_opt ? null,
      ports ? null,
      pid ? null,
      tmpfs ? null,
      ...
    }: image:
    concatStringsSep " " (
      [ "docker run"]
      ++ optional init "--init"
      ++ optional read_only "--read-only"
      ++ optional (pid != null) "--pid=${pid}"
      ++ optional (network != null) "--network=${network}"
      ++ optionals (volumes != null) map dockerMountArg volumes
      ++ optionals (tmpfs != null) (map (o: "--tmpfs ${o}") tmpfs)
      ++ optionals (environment != null) (map (e: "-e ${e}") (setToKeyVal environment))
      ++ optionals (ulimits != null) (map dockerUlimitArg ulimits)
      ++ optionals (cap_add != null) (map (c: "--cap-add ${c}") cap_add)
      ++ optionals (cap_drop != null) (map (c: "--cap-drop ${c}") cap_drop)
      ++ optionals (security_opt != null) (map (o: "--security-opt ${o}") security_opt)
      ++ optionals (ports != null) (map (o: "--publish ${o}") ports)
      ++ [ image ]
  );

  mkRootfs = { name ? "rootfs", src, ... }@s: pkgs.stdenv.mkDerivation (s // {
    buildInputs = attrsets.collect attrsets.isDerivation s;
    phases = [ "buildPhase" "installPhase" ];
    buildPhase = ''
      export rootfs="$out"
      export self="$out"
      export this="$out"
      export PATH=$PATH:${pkgs.findutils}/bin:${pkgs.rsync}/bin
      env
      mkdir build
      rsync -qav ${src}/ build/
      for file in $(find build -type f)
      do
        echo "Making substitutions in $file"
        substituteAllInPlace "$file"
      done
    '';
    installPhase = ''
      ${pkgs.rsync}/bin/rsync -qav build/ $out/
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
        "/run/php${versions.major php.version +
                   versions.minor php.version}.d:mode=644";

      ulimits = [
        { name = "stack"; hard = -1; soft = -1; }
      ];
      security_opt = [ "apparmor:unconfined" ];
      cap_add = [ "SYS_ADMIN" ];
      volumes = [
        ({ type = "bind";
           source = "/etc/ssl";
           target = "/etc/ssl";
           read_only = true;
         })
        ({ type = "bind";
           source = "$SITES_CONF_PATH" ;
           target = "/read/sites-enabled";
           read_only = true;
         })
        ({ type = "bind";
           source =  "/opt/etc";
           target = "/opt/etc";
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
        ({ type = "tmpfs"; target = "/run";})
      ];
    };

  buildPhpPackage = {
    name,
    version,
    php,
    sha256 ? null,
    src ? pkgs.fetchurl {
      url = "http://pecl.php.net/get/${name}-${version}.tgz";
      inherit (args) sha256;
    },
    inputs ? [],
    ...
  }@args:
  pkgs.stdenv.mkDerivation (args // { name = "${php.name}-${name}-${version}"; } // rec {
    inherit src;
    buildInputs = [ pkgs.autoreconfHook php ] ++ inputs;
    makeFlags = [ "EXTENSION_DIR=$(out)/lib/php/extensions" ];
    autoreconfPhase = "phpize";
    checkTarget = "test";
    # XXX:
    doCheck = if ("timezonedb" != "timezonedb" && "rrd" != "rrd") then true else false;
    postInstall = [''
      ls $out/lib/php/extensions/${name}.so || mv $out/lib/php/extensions/*.so $out/lib/php/extensions/${name}.so
    '']
    ++ optional (name != "zendopcache")
    ''
      mkdir -p  $out/etc/php${versions.major php.version + versions.minor php.version}.d
      echo "extension = $out/lib/php/extensions/${name}.so" > $out/etc/php${versions.major php.version + versions.minor php.version}.d/${name}.ini
    '';
    preCheck = ''
    for test in \
        tests/015-imagickdrawsetresolution.phpt \
    tests/016-static-methods.phpt \
    tests/034_Imagick_annotateImage_basic.phpt \
    tests/150_Imagick_setregistry.phpt \
    tests/177_ImagickDraw_composite_basic.phpt \
    tests/206_ImagickDraw_setFontSize_basic.phpt \
    tests/207_ImagickDraw_setFontFamily_basic.phpt \
    tests/208_ImagickDraw_setFontStretch_basic.phpt \
    tests/209_ImagickDraw_setFontWeight_basic.phpt \
    tests/210_ImagickDraw_setFontStyle_basic.phpt \
    tests/212_ImagickDraw_setGravity_basic.phpt \
    tests/222_ImagickDraw_setTextAlignment_basic.phpt \
    tests/223_ImagickDraw_setTextAntialias_basic.phpt \
    tests/224_ImagickDraw_setTextUnderColor_basic.phpt \
    tests/225_ImagickDraw_setTextDecoration_basic.phpt \
    tests/241_Tutorial_psychedelicFont_basic.phpt \
    tests/244_Tutorial_psychedelicFontGif_basic.phpt \
    tests/254_getConfigureOptions.phpt \
    tests/264_ImagickDraw_getTextDirection_basic.phpt \
    tests/266_ImagickDraw_getFontResolution_basic.phpt \
    tests/268_ImagickDraw_getDensity_basic.phpt \
    ext/268_ImagickDraw_getDensity_basic.phpt \
    \
    tests/compression_conditions.phpt \
    tests/set_encoding_key.phpt \
    \
    ; do
        test -f $test && rm $test;
    done
    '';
  });

}
