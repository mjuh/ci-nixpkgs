{ pkgs, image }:

with pkgs;

writeScript "runDockerImage.sh" ''
  #!${bash}/bin/bash
  # Run Docker image with ru.majordomo.docker.cmd label.
  set -e -x
  ${(lib.importJSON (image.baseJson)).config.Labels."ru.majordomo.docker.cmd"} &
''
