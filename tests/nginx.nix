{ pkgs, firefox, debug ? false, bash, image, jq, lib, php, rsync
, stdenv, wordpress, wrk2, writeScript, python3
, phpinfo, testDiffPy, wordpressScript, wrkScript
, keydir, confdir 
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
  loadContainer = writeScript "loadContainer.sh" ''
    #!/bin/sh -eux
    ${pkgs.docker}/bin/docker load --input ${image}
  '';

  runNginxContainer = writeScript "runNginxContainer.sh" ''
    #!/bin/sh -eux
    ${pkgs.docker}/bin/${let
                           cmd = lib.splitString " " ((lib.importJSON (image.baseJson)).config.Labels."ru.majordomo.docker.cmd");
                         in
                           builtins.concatStringsSep " " (((lib.init cmd) ++ ["--name nginx"]) ++ [(lib.last cmd)])} &
  '';
  
in import maketest ({ pkgs, lib, ... }: {
  name = "nginx";
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
      #networking.hostName = if debug then "dockerNode${phpVersion}" else "dockerNode";
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
        chromium
      ];

      environment.variables.SECURITY_LEVEL = "default";
#      environment.variables.SITES_CONF_PATH =
#        "/etc/apache2-${phpVersion}-default/sites-enabled";
      environment.variables.SOCKET_HTTP_PORT = "80";
      environment.interactiveShellInit = ''
        alias ll='ls -alF'
        alias s='sudo -i'
        alias show-tests='ls /nix/store/*{test,run,wordpress}*{sh,py}'
        alias list-tests='ls /nix/store/*{test,run,wordpress}*{sh,py}'
      '';
#      boot.initrd.postMountCommands = postMountCommands;
#      nixpkgs.config.packageOverrides = pkgs: rec {
#        docker = pkgs.docker_18_09;
#      };

      systemd.services.docker.postStart = ''
          #set -e -x
          echo ${image}
          mkdir -p /home/nginx /opt/nginx/conf /etc/nginx/ssl.key /etc/nginx/sites-available /home/nginx /home
          cp -rv ${keydir}/* /etc/nginx/ssl.key
          cp -rv ${confdir}/* /opt/nginx/conf
          ${pkgs.docker}/bin/docker rm -f nginx || true
          ${pkgs.docker}/bin/docker load --input ${image}
          ${pkgs.rsync}/bin/rsync -av /etc/{passwd,group,shadow} /opt/etc/ > /dev/null
          ${pkgs.netcat-gnu}/bin/nc -zvv 127.0.0.1 80 || ${runNginxContainer}
          until [[ $(${pkgs.docker}/bin/docker ps | grep [n]ginx) ]] ; do sleep 1  ;done
          until [[ $(${pkgs.procps}/bin/ps | grep [n]ginx) ]] ; do sleep 1  ;done
          until [[ $(${pkgs.curl}/bin/curl -f -I -L -s -o /dev/null -w %{http_code} http://127.0.0.1) -eq 403  ]] ; do sleep 1  ; done
      '';

      networking.interfaces."lo".ip4 = [
         { address = "127.0.0.2"; prefixLength = 32; }
         { address = "127.0.0.3"; prefixLength = 32; }
         { address = "127.0.0.4"; prefixLength = 32; }
         { address = "127.0.0.5"; prefixLength = 32; }
      ];
    };
  };

  testScript = [''
    print "Tests entry point.\n";
    startAll;

    print "Start services.\n";
    $dockerNode->waitForUnit("docker");
#    $dockerNode->succeed("${loadContainer}");
  '']

    ++ testSuite;

})
