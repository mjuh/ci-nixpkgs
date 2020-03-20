{ stdenv, writeScript }:

stdenv.mkDerivation rec {
  name = "zabbix-agentd-conf";
  src = builtins.fetchGit {
    url = "git@gitlab.intr:chef/service.git";
    ref = "master";
  };
  builder = writeScript "builder.sh" ''
    source $stdenv/setup
    mkdir -p $out/etc/zabbix_agentd.conf.d
    for file in $src/templates/default/zabbix/*; do
      cp $file .
      substituteInPlace $(basename $file) --replace '<%= @scripts_dir %>' $out/etc/zabbix_agentd.conf.d/userparameter_$(basename $file .erb).conf
      substituteInPlace $(basename $file) --replace '<%= @home_dir %>' /etc/zabbix || true
      cp ./$(basename $file) $out/etc/zabbix_agentd.conf.d/userparameter_$(basename $file .erb).conf
    done
  '';
}
