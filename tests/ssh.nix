{ pkgs, firefox, debug ? false, bash, image, lib, rootfs, stdenv, wordpress
, wrk2, writeScript, python3, containerStructureTestConfig, dockerNodeTest
, containerStructureTest, testImages, testSuite ? [ ] }:

with lib;

let
  maketest = <nixpkgs/nixos/tests> + /make-test.nix;
  runDockerImage = import ./scripts/runDockerImage.nix;
in import maketest ({ pkgs, lib, ... }: {
  name = "ssh-guest-room";
  nodes = {
    dockerNode = { pkgs, ... }: {
      virtualisation = {
        cores = 3;
        memorySize = 8 * 1024;
        diskSize = 10 * 1024;
        docker.enable = true;
        dockerPreloader = {
          images = [ image ] ++ map pkgs.dockerTools.pullImage testImages;
          qcowSize = 10 * 1024;
        };
        qemu.networkingOptions = if debug then [
          "-net nic,model=virtio"
          "-net user,hostfwd=tcp::2222-:22"
        ] else [
          "-net nic,model=virtio"
          "-net user"
        ];
      };

      users.users = {
        u12 = {
          isNormalUser = true;
          description = "Test user";
          password = "foobar";
        };
        www-data = {
          isNormalUser = false;
          uid = 33;
        };
        admin = {
          isNormalUser = true;
          password = "admin";
          extraGroups = [ "wheel" ];
          openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC35V1L3xgGA7DIdUCRzLpOjeaUi+qt2Gb5DV67ifmyw5i7UH9onVen6FQKMkuQBn0hVu9h9XVV30lGtCXj7Des/FXpV9OW3MRbWKxmekDshZHu+QkhZer9i+Nd413Q+UDzJGANUwJ71mr3H3rqTDZnWN/LQGkGv8xR/mK4vWfAWgidi1sdABgoEh0gN80Oa2VMhsX0Nx2VmCv5k7mftajADKnTc6paZGzCaShNgTlExZEHRfUUqXb1Yk3gifIZNxhdbcplmRLeMccbYnv0i7cg8TekH+3VmeS+JWNYVHrxHuic/L9otSL7HXnmnlAawmMQLZPUTCIMQP4kWju7I0BGCC2tUpm8OZvxtXtbHjLk5oX+Oe66IV142ORwvH/mWnOWs9JeafcGpP1VerpBTmPeQi3flbKOGCAGCeQtnLO8XPIx6FzNAfzrJJX05tvzo5Hau9ukDwLEzk+0+fb1biJOqbYFdwoj/mFBIwKLzAoOGw2v7UZmLAzPUFaKiZki4NgRpq5Myrc1xcn39h5jjMZU1K29lVxbMjYE3ikHrUOEYCsPQwL5KEKVIQRqk6UZY4FxApeSgoiCftbWGXpjheCHOUyd9+MtlL/Q1aWbxkMT5eNmFvMVm7hfLZqXje0lAnJJOX+KgyoHnNqmAmZsauUreW/mfhTFHFTCG8wpW50s3w==" ];
        };
      };

      security.sudo.enable = true;
      security.sudo.extraConfig = ''
         admin  ALL=NOPASSWD: ALL
      '';

      services.openssh.enable = if debug then true else false;
      services.openssh.permitRootLogin = if debug then "yes" else "no";

      environment.variables.SSHD_PORT = "1022";
      environment.variables.SSHD_ADDR = "0.0.0.0";
      boot.initrd.postMountCommands =
        import ./boot-initrd-postMountCommands.nix { phpVersion = "php74"; };

    };
  };

  testScript = [''
    print "Tests entry point.\n";
    startAll;
    print "Start services.\n";
    $dockerNode->execute("${runDockerImage { inherit pkgs; inherit image; }}");
    $dockerNode->sleep(10);
  ''] ++ testSuite;
})
