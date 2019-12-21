{ pkgs, config, image, tag ? "latest" }:

with pkgs;

writeScript "docker-run-container-structure-test.sh" ''
  #!${bash}/bin/bash
  exec &> /tmp/xchg/coverage-data/container-structure-test.html

  ${builtins.concatStringsSep " " [
    "docker"
    "run"
    "--privileged"
    "--rm"
    "--name"
    "container-structure-test"
    "--volume"
    "${config}:/container-structure-test.yaml"
    "--volume"
    "/var/run/docker.sock:/var/run/docker.sock"
    "gcr.io/gcp-runtimes/container-structure-test:latest"
    "test"
    "--image"
    "${image}:${tag}"
    "--config"
    "container-structure-test.yaml"
  ]}
    ''

