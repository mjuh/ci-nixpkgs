{ pkgs }:

with pkgs.lib;

rec {
  dropAttr = name: set: attrsets.filterAttrs (n: _: n != name) set;

  dropAttrs = names: set: (lists.foldr dropAttr set) names;

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
      hostname ? null,
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
      ++ optional (hostname != null) "--hostname=${hostname}"
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

  phpDockerArgHints = import ./php-docker-arg-hints.nix;

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
    doCheck = true;
    REPORT_EXIT_STATUS = "1";
    TEST_PHP_ARGS = "-q";
    postInstall = [''
      ls $out/lib/php/extensions/${name}.so || mv $out/lib/php/extensions/*.so $out/lib/php/extensions/${name}.so
    '']
    ++ optional (name != "zendopcache")
    ''
      mkdir -p  $out/etc/php${versions.major php.version + versions.minor php.version}.d
      echo "extension = $out/lib/php/extensions/${name}.so" > $out/etc/php${versions.major php.version + versions.minor php.version}.d/${name}.ini
    '';
  });

  buildPhpPearPackage = {
    name,
    version,
    php,
    sha256 ? null,
    src ? pkgs.fetchurl {
      url = "http://download.pear.php.net/package/${name}-${version}.tgz";
      inherit (args) sha256;
    },
      inputs ? [],
      package ? null,
    ...
  }@args:
  pkgs.stdenv.mkDerivation (args // { name = "${php.name}-${name}-${version}"; } // rec {
    inherit src;
    buildInputs = [ pkgs.autoreconfHook php ] ++ inputs;
    phases = ["installPhase" ];
    installPhase = ''
      mkdir -p $out/lib/php
      tar --strip-components=1 -C $out/lib/php -xf ${src} ${package}
    '';
  });

  php2version = php:
    "php" + versions.major php.version + versions.minor php.version;
}
