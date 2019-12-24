{ pkgs, firefox, debug ? false, bash, image, lib, rootfs, stdenv, wordpress
, wrk2, writeScript, python3, containerStructureTestConfig, dockerNodeTest
, containerStructureTest, testImages, testSuite ? [ ] }:

with lib;

let
  maketest = <nixpkgs/nixos/tests> + /make-test.nix;

in import maketest ({ pkgs, lib, ... }: {
  name = "ssh-guest-room";
  nodes = {
    dockerNode = { pkgs, ... }: {
      virtualisation = {
        cores = 3;
        memorySize = 8 * 1024;
        diskSize = 4 * 1024;
        docker.enable = true;
        dockerPreloader = {
          images = [ image ] ++ map pkgs.dockerTools.pullImage testImages;
          qcowSize = 4 * 1024;
        };
        qemu.networkingOptions = if debug then [
          "-net nic,model=virtio"
          "-net user,hostfwd=tcp::2222-:22"
        ] else [
          "-net nic,model=virtio"
          "-net user"
        ];
      };

      services.openssh.enable = if debug then true else false;
      services.openssh.permitRootLogin = if debug then "yes" else "no";

      environment.variables.SSHD_PORT = "1022";
      environment.variables.SSHD_ADDR = "0.0.0.0";
    };
  };

  testScript = [''
    print "Tests entry point.\n";
    startAll;
  ''] ++ testSuite;
})
