{ pkgs, firefox, debug ? false, bash, image, vimage, testvenv, pip-dependencies, democms, jq, lib, php, rsync
, stdenv, wordpress, wrk2, writeScript, python3
, phpinfo, testDiffPy, wordpressScript, wrkScript
, dockerNodeTest, containerStructureTest, testImages, testSuite ? [ ], runCurl
, postMountCommands ? (import ./boot-initrd-postMountCommands.nix {
  phpVersion = (lib.php2version php);
}) }:

# Run virtual machine, then container with Apache and PHP, and test it.

with lib;

let
  maketest = <nixpkgs/nixos/tests> + /make-test.nix;
  inherit pkgs;
  inherit image;
  inherit vimage;
  inherit democms;
  inherit testvenv;
  inherit pip-dependencies;
  loadContainer = writeScript "loadContainer.sh" ''
    #!/bin/sh -eux
    ${pkgs.docker}/bin/docker load --input ${image}
    ${pkgs.docker}/bin/docker load --input ${vimage}
  '';

   runUwsgiContainer =  writeScript "runUwsgiContainer.sh" ''
    #!/bin/sh -eux
    ${pkgs.docker}/bin/${let
                           cmd = lib.splitString " " ((lib.importJSON (image.baseJson)).config.Labels."ru.majordomo.docker.cmd");
                         in
                           builtins.concatStringsSep " " (((lib.init cmd) ++ ["--name uwsgi"]) ++ [(lib.last cmd)])} &

  '';

   deployPhase = writeScript "deployPhase.sh" ''
    #!/bin/sh -eux
    cd /home/u6666/
    chown -R 6666:6666 /home/u6666/
    docker run --rm \
               -u 6666:6666 -e DOCUMENT_ROOT=/home/u6666/examplecom/www \
               -e DOMAIN_NAME=example.com -v /home/u6666:/workdir docker-registry.intr/webservices/python37-venv:latest install
   '';

   releasePhase = writeScript "releasePhase.sh" ''
    #!/bin/sh -eux
    mkdir -p /home/u6666/examplecom/www/bakerydemo/collect_static
    chmod +w /home/u6666/examplecom/www/bakerydemo/media/
    chown -R 6666:6666 /home/u6666/
    docker run --rm \
               -u 6666:6666 -e DOCUMENT_ROOT=/home/u6666/examplecom/www \
               -e DOMAIN_NAME=example.com -v /home/u6666:/workdir docker-registry.intr/webservices/python37-venv:latest \
               './manage.py migrate && ./manage.py load_initial_data && yes yes | ./manage.py collectstatic'
   '';

in import maketest ({ pkgs, lib, ... }: {
  name = "uwsgi";
  nodes = {
    dockerNode = { pkgs, ... }: {
      virtualisation = {
        cores = 2;
        memorySize = 4 * 1024;
        diskSize = 4 * 1024;
        docker.enable = true;
        qemu.networkingOptions = if debug then [
          "-net nic,model=virtio"
          "-net user,hostfwd=tcp::2222-:22"
        ] else [
          "-net nic,model=virtio"
          "-net user"
        ];
      };
      users.users = {
        u6666 = {
          isNormalUser = true;
          description = "Test user";
          password = "foobar";
          uid = 6666;
        };
        www-data = {
          isNormalUser = false;
          uid = 33;
        };
        admin = {
          isNormalUser = true;
          password = "admin";
          extraGroups = [ "wheel" ];
          openssh.authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC35V1L3xgGA7DIdUCRzLpOjeaUi+qt2Gb5DV67ifmyw5i7UH9onVen6FQKMkuQBn0hVu9h9XVV30lGtCXj7Des/FXpV9OW3MRbWKxmekDshZHu+QkhZer9i+Nd413Q+UDzJGANUwJ71mr3H3rqTDZnWN/LQGkGv8xR/mK4vWfAWgidi1sdABgoEh0gN80Oa2VMhsX0Nx2VmCv5k7mftajADKnTc6paZGzCaShNgTlExZEHRfUUqXb1Yk3gifIZNxhdbcplmRLeMccbYnv0i7cg8TekH+3VmeS+JWNYVHrxHuic/L9otSL7HXnmnlAawmMQLZPUTCIMQP4kWju7I0BGCC2tUpm8OZvxtXtbHjLk5oX+Oe66IV142ORwvH/mWnOWs9JeafcGpP1VerpBTmPeQi3flbKOGCAGCeQtnLO8XPIx6FzNAfzrJJX05tvzo5Hau9ukDwLEzk+0+fb1biJOqbYFdwoj/mFBIwKLzAoOGw2v7UZmLAzPUFaKiZki4NgRpq5Myrc1xcn39h5jjMZU1K29lVxbMjYE3ikHrUOEYCsPQwL5KEKVIQRqk6UZY4FxApeSgoiCftbWGXpjheCHOUyd9+MtlL/Q1aWbxkMT5eNmFvMVm7hfLZqXje0lAnJJOX+KgyoHnNqmAmZsauUreW/mfhTFHFTCG8wpW50s3w=="
          ];
        };
      };

      security.sudo.enable = true;
      security.sudo.extraConfig = ''
        admin  ALL=NOPASSWD: ALL
      '';

      services.openssh.enable = if debug then true else false;
      services.openssh.permitRootLogin = if debug then "yes" else "no";
      environment.systemPackages = with pkgs; [
        rsync
        mc
        tree
        jq
        docker
        tmux
        curl
        yq

        (import (builtins.fetchGit {
          url = "https://gitlab.intr/utils/catj.git";
          ref = "master";
        }) { }).catj

        (stdenv.mkDerivation {
          name = "run-container-uwsgi";
          builder = writeScript "builder.sh" (''
            source $stdenv/setup
            mkdir -p $out/bin
            cat > $out/bin/run-container-uwsgi <<'EOF'
            ${runUwsgiContainer}
            EOF
            chmod 555 $out/bin/run-container-uwsgi
          ''
        );})
      ];

      environment.variables.SECURITY_LEVEL = "default";
      environment.variables.DOCUMENT_ROOT = "/home/u6666/examplecom/www";
      environment.variables.DOMAIN_NAME = "example.com";
      environment.variables.SOCKET_HTTP_PORT = "80";
      environment.interactiveShellInit = ''
        alias ll='ls -alF'
        alias s='sudo -i'
        alias show-tests='ls /nix/store/*{test,run,wordpress}*{sh,py}'
        alias list-tests='ls /nix/store/*{test,run,wordpress}*{sh,py}'
      '';
      systemd.services.docker.postStart = ''
          #set -e -x
          mkdir -p /home/u6666/examplecom/www
          cp -vr ${democms}/* /home/u6666/examplecom/www/
          cp -vr  /home/u6666/examplecom/www/bakerydemo/settings/local.py.example  /home/u6666/examplecom/www/bakerydemo/settings/local.py
          echo 'ALLOWED_HOSTS = "*"' >> /home/u6666/examplecom/www/bakerydemo/settings/local.py
          echo 'DJANGO_SETTINGS_MODULE=bakerydemo.settings.local' > /home/u6666/examplecom/www/.env
          chown -R 6666:6666 /home/u6666/
          echo ${image}
          echo ${vimage}
          ${pkgs.docker}/bin/docker rm -f uwsgi || true
          ${pkgs.docker}/bin/docker load --input ${image}
          ${pkgs.docker}/bin/docker load --input ${vimage}

      '';

    };
  };

  testScript = [''
    print "Tests entry point.\n";
    startAll;

    print "Start services.\n";
    $dockerNode->waitForUnit("docker");
    print $dockerNode->succeed("${deployPhase}");
    print $dockerNode->succeed("${releasePhase}");
  '']

    ++ testSuite;

})
