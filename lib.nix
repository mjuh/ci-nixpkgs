{ pkgs }:

with pkgs.lib;

rec {
  firstNChars = n: str: concatStrings (take n (stringToCharacters str));

  flattenSetSep = sep: set: listToAttrs (collect (x: x ? name) (mapAttrsRecursive (p: v: attrsets.nameValuePair (builtins.concatStringsSep sep p) v) set));

  flattenSet = set: flattenSetSep "." set;

  keyValOrBoolKey = k: v: if isBool v then optionalString v "${k}" else "${k}=${v}";

  setToCommaSep = x: concatStringsSep "," (mapAttrsToList keyValOrBoolKey x);

  setToKeyVal = x: mapAttrsToList (k: v: "${k}=${v}") x;

  dockerMountArg = volume: "--mount " + setToCommaSep (flattenSetSep "-" (mapAttrs' (n: v: nameValuePair (builtins.replaceStrings ["_"] [""] n) v) volume));

  dockerRunCmd = {
      init ? false,
      read_only ? false,
      network ? null,
      volumes ? null,
      environment ? null,
      ...
    }: image:
    concatStringsSep " " (
      [ "docker run"]
      ++ optional init "--init"
      ++ optional read_only "--read-only"
      ++ optional (network != null) "--network=${network}"
      ++ optionals (volumes != null) map dockerMountArg volumes
      ++ optionals (environment != null) (map (e: "-e ${e}") (setToKeyVal environment))
      ++ [ image ]
  );
}
