{ pkgs ? import <nixpkgs> { }, image }:

with pkgs;

writeScript "runDockerImage.sh" ''
  #!${bash}/bin/bash
  # Run Docker image with ru.majordomo.docker.cmd label.
  ${rsync}/bin/rsync -av /etc/{passwd,group,shadow} /opt/etc/ > /dev/null
  set -e -x
  ${docker}/bin/${(builtins.fromJSON(builtins.unsafeDiscardStringContext (builtins.readFile image.baseJson))).config.Labels."ru.majordomo.docker.cmd"} &
''
