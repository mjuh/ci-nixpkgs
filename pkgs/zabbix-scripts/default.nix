{ stdenv, writeScript, perl, python }:

stdenv.mkDerivation rec {
  name = "zabbix-scripts";
  src = builtins.fetchGit {
    url = "git@gitlab.intr:staff/zabbix-scripts.git";
    ref = "master";
  };
  builder = writeScript "builder.sh" ''
    source $stdenv/setup
    mkdir -p $out/share/zabbix-scripts
    export PATH=${python}/bin:${perl}/bin:$PATH
    for file in $src/*; do
      cp $file .
      patchShebangs $(basename $file)
      cp ./$(basename $file) $out/share/zabbix-scripts
    done
  '';
}
