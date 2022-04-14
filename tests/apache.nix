{ pkgs
, firefox
, debug ? false
, bash
, image
, jq
, lib
, php
, phpinfoCompare
, rootfs
, stdenv
, wordpress
, wrk2
, writeScript
, python3
, containerStructureTestConfig
, phpinfo
, testDiffPy
, wordpressScript
, wrkScript
, dockerNodeTest
, containerStructureTest
, testImages
, testSuite ? [ ]
, runCurl
, postMountCommands ? (import ./boot-initrd-postMountCommands.nix {
    phpVersion = (lib.php2version php);
  })
, runDockerImage ? import ./scripts/runDockerImage.nix
, runApacheContainer ? runDockerImage {
    inherit pkgs;
    inherit image;
  }
, testApachePHPwithPerl ? true
}:

# Run virtual machine, then container with Apache and PHP, and test it.

with lib;

let
  phpVersion = php2version php;
  domain = phpVersion + ".ru";

  pullContainers = writeScript "pullContainers.sh" ''
    #!/bin/sh -eux
    ${builtins.concatStringsSep "; "
    (map (container: "${pkgs.docker}/bin/docker load --input ${container}")
      ([ image ] ++ map pkgs.dockerTools.pullImage testImages))}
  '';

in
lib.maketest ({ pkgs, lib, ... }: {
  name = lib.concatStringsSep "-" [ "apache2" phpVersion "default" ];
  nodes = {
    dockerNode = { pkgs, ... }: {
      virtualisation = {
        cores = 3;
        memorySize = 4 * 1024;
        diskSize = 4 * 1024;
        docker.enable = true;
        qemu.networkingOptions =
          if debug then [
            "-net nic,model=virtio"
            "-net user,hostfwd=tcp::2222-:22"
          ] else [
            "-net nic,model=virtio"
            "-net user"
          ];
      };
      #      nixpkgs.config.packageOverrides = pkgs: rec {
      #        docker = pkgs.docker_18_09;
      #      };
      networking.extraHosts = "127.0.0.1 ${domain}";
      #networking.hostName = if debug then "dockerNode${phpVersion}" else "dockerNode";
      users.users = {
        u12 = {
          isNormalUser = true;
          description = "Test user";
          password = "foobar";
          uid = 12345;
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
      ];

      environment.variables.SECURITY_LEVEL = "default";
      environment.variables.SITES_CONF_PATH =
        "/etc/apache2-${phpVersion}-default/sites-enabled";
      environment.variables.SOCKET_HTTP_PORT = "80";
      environment.interactiveShellInit = ''
        alias ll='ls -alF'
        alias s='sudo -i'
        alias show-tests='ls /nix/store/*{test,run,wordpress}*{sh,py}'
        alias list-tests='ls /nix/store/*{test,run,wordpress}*{sh,py}'
      '';

      systemd.tmpfiles.rules = [
        "d /etc/cgconfig.d 755 root root -"
        "d /etc/apparmor.d 755 root root -"
        "d /var/log/cron 755 root root -"
        "d /var/log/home 755 root root -"
        "d /opt 755 root root -"
        "d /run/mysqld 777 root root -"
        "d /opt/etc 755 root root -"
        "d /opt/run 755 root root -"
      ];

      boot.initrd.postMountCommands = postMountCommands;

      services.mysql.enable = true;
      services.mysql.initialScript = pkgs.writeText "mariadb-init.sql" ''
        ALTER USER root@localhost IDENTIFIED WITH unix_socket;
        DELETE FROM mysql.user WHERE password = ''' AND plugin = ''';
        DELETE FROM mysql.user WHERE user = ''';
        CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'password123';
        CREATE USER 'old'@'localhost' IDENTIFIED BY '07ce55792eafa749';
        SET PASSWORD FOR 'old'@'localhost' = OLD_PASSWORD('password123');
        SET GLOBAL secure_auth=0;
        FLUSH PRIVILEGES;
      '';
      services.mysql.ensureDatabases = [ "wordpress" "oldpasswords" ];
      services.mysql.ensureUsers = [
        {
          name = "wordpress_user";
          ensurePermissions = { "wordpress.*" = "ALL PRIVILEGES"; };
        }
        {
          name = "old";
          ensurePermissions = { "oldpasswords.*" = "ALL PRIVILEGES"; };
        }
      ];
      services.mysql.package = pkgs.mariadb;
      systemd.services.docker.postStart = ''
        docker container prune -f  >/dev/null || true
        mkdir -p /opt/run
        export SECURITY_LEVEL="default";
        export SITES_CONF_PATH="/etc/apache2-${phpVersion}-default/sites-enabled";
        export SOCKET_HTTP_PORT="80";
        ${builtins.concatStringsSep "; "
          (map (container: "${pkgs.docker}/bin/docker load --input ${container}")
            ([ image ] ++ map pkgs.dockerTools.pullImage testImages))}
        ${pkgs.netcat-gnu}/bin/nc -zvv 127.0.0.1 $SOCKET_HTTP_PORT || ${runApacheContainer}
        until [[ $(${pkgs.curl}/bin/curl -f -I -L -s -o /dev/null -w %{http_code} http://127.0.0.1/server-status) -eq 200 ]] ; do sleep 1 ; done
      '';
    };
  };

  testScript = [
    ''
      print "Tests entry point.\n";
      startAll;
      print "Start services.\n";
      $dockerNode->waitForUnit("mysql");
      $dockerNode->waitForUnit("docker");
    ''
  ]

  ++ testSuite

  ++ optional testApachePHPwithPerl [
    (dockerNodeTest {
      description = "Perl version";
      action = "succeed";
      command = ''
        #!{bash}/bin/bash
        docker exec `docker ps --format '{{ .Names }}' ` perl -v | grep 'v5.20'
      '';
    })
    (dockerNodeTest {
      description = "Perl Crypt::RC4";
      action = "succeed";
      command = ''
        #!${pkgs.runtimeShell}
        docker exec `docker ps --format '{{ .Names }}'` perl -e 'use Crypt::RC4;'
      '';
    })
    (dockerNodeTest {
      description = "Perl Spreadsheet::ParseExcel";
      action = "succeed";
      command = ''
        #!${pkgs.runtimeShell}
        docker exec `docker ps --format '{{ .Names }}'` perl -e 'use Spreadsheet::ParseExcel;'
      '';
    })
  ];
})
