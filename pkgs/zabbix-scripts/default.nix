{ stdenv, writeScript, curl, perl, python, mdadm }:

stdenv.mkDerivation rec {
  name = "zabbix-scripts";
  src = builtins.fetchGit {
    url = "git@gitlab.intr:staff/zabbix-scripts.git";
    ref = "master";
  };
  builder = writeScript "builder.sh" ''
    source $stdenv/setup
    mkdir -p $out/share/zabbix-scripts
    export PATH=${python}/bin:${perl}/bin:${mdadm}/bin:$PATH
    for file in $src/*; do
      cp $file .
      patchShebangs $(basename $file)
      sed -i 's@/sbin/mdadm@${mdadm}/bin/mdadm@g' $(basename $file)
      substituteInPlace "$(basename $file)" --replace '$(which curl)' ${curl}/bin/curl
      cp ./$(basename $file) $out/share/zabbix-scripts
    done
  '';
}
