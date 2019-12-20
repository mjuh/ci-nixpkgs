{ pkgs, debug ? false, bash, image, jq, lib, php, phpinfoCompare, rootfs, stdenv
, wordpress, wrk2, writeScript, python3, deepdiff }:

# Run virtual machine, then container with Apache and PHP, and test it.

with lib;

let
  maketest = <nixpkgs/nixos/tests> + /make-test.nix;

  phpinfo = writeScript "phpinfo.php" ''
    <?php phpinfo(); ?>
  '';

  testDiffPy = import ./scripts/deepdiff.nix;

  runDockerImage = image:
    writeScript "runDockerImage.sh" ''
      #!${bash}/bin/bash
      # Run Docker image with ru.majordomo.docker.cmd label.
      set -e -x
      ${
        (lib.importJSON
          (image.baseJson)).config.Labels."ru.majordomo.docker.cmd"
      } &
    '';

  php2version = php:
    "php" + lib.versions.major php.version + lib.versions.minor php.version;

  wordpressScript = import ./scripts/wordpress.nix;
  wrkScript = import ./scripts/wrk.nix;

  phpVersion = php2version php;
  domain = phpVersion + ".ru";

in import maketest ({ pkgs, lib, ... }: {
  name = lib.concatStringsSep "-" [ "apache2" phpVersion "default" ];
  nodes = {
    dockerNode = { pkgs, ... }: {
      virtualisation = {
        cores = 3;
        memorySize = 4 * 1024;
        diskSize = 4 * 1024;
        docker.enable = true;
        dockerPreloader = {
          images = [ image ];
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

      networking.extraHosts = "127.0.0.1 ${domain}";
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
      };

      services.openssh.enable = if debug then true else false;
      services.openssh.permitRootLogin = if debug then "yes" else "no";

      environment.variables.SECURITY_LEVEL = "default";
      environment.variables.SITES_CONF_PATH =
        "/etc/apache2-${phpVersion}-default/sites-enabled";
      environment.variables.SOCKET_HTTP_PORT = "80";

      boot.initrd.postMountCommands =
        import ./boot-initrd-postMountCommands.nix { inherit phpVersion; };

      services.mysql.enable = true;
      services.mysql.initialScript = pkgs.writeText "mariadb-init.sql" ''
        ALTER USER root@localhost IDENTIFIED WITH unix_socket;
        DELETE FROM mysql.user WHERE password = ''' AND plugin = ''';
        DELETE FROM mysql.user WHERE user = ''';
        CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'password123';
        FLUSH PRIVILEGES;
      '';
      services.mysql.ensureDatabases = [ "wordpress" ];
      services.mysql.ensureUsers = [{
        name = "wordpress_user";
        ensurePermissions = { "wordpress.*" = "ALL PRIVILEGES"; };
      }];
      services.mysql.package = pkgs.mariadb;
    };
  };

  testScript = [''
    startAll;

    print "Start services.\n";
    $dockerNode->waitForUnit("mysql");
    $dockerNode->execute("${runDockerImage image}");
    $dockerNode->sleep(10);

    print "Get phpinfo.\n";
    $dockerNode->execute("cp -v ${phpinfo} /home/u12/${domain}/www/phpinfo.php");
    $dockerNode->succeed("curl --connect-timeout 30 -f --silent --output /tmp/xchg/coverage-data/phpinfo.html http://${domain}/phpinfo.php");

    print "Get server-status.\n";
    $dockerNode->succeed("curl --connect-timeout 30 -f --silent --output /tmp/xchg/coverage-data/server-status.html http://127.0.0.1/server-status");

    print "Get PHP diff.\n";
    $dockerNode->succeed("cp -v ${
      ./phpinfo-json.php
    } /home/u12/${phpVersion}.ru/www/phpinfo-json.php");
    $dockerNode->succeed("curl --output /tmp/xchg/coverage-data/phpinfo.json --silent http://${phpVersion}.ru/phpinfo-json.php");
    $dockerNode->succeed("${
      testDiffPy {
        inherit pkgs;
        sampleJson = (./. + "/${phpVersion}.json");
        output = "/tmp/xchg/coverage-data/deepdiff.html";
      }
    }");
    $dockerNode->succeed("${
      testDiffPy {
        inherit pkgs;
        sampleJson = (./. + "/${phpVersion}.json");
        output = "/tmp/xchg/coverage-data/deepdiff-with-excludes.html";
        excludes = import ./diff-to-skip.nix;
      }
    }");
    $dockerNode->succeed("${
      testDiffPy {
        inherit pkgs;
        sampleJson = (./. + "/web34/${phpVersion}.json");
        output = "/tmp/xchg/coverage-data/deepdiff-web34.html";
      }
    }");
    $dockerNode->succeed("${
      testDiffPy {
        inherit pkgs;
        sampleJson = (./. + "/web34/${phpVersion}.json");
        output = "/tmp/xchg/coverage-data/deepdiff-web34-with-excludes.html";
        excludes = import ./diff-to-skip.nix;
      }
    }");

    print "Run Bitrix test.\n";
    $dockerNode->succeed("cp -v ${
      ./bitrix_server_test.php
    } /home/u12/${domain}/www/bitrix_server_test.php");
    $dockerNode->succeed("curl --connect-timeout 30 -f --silent --output /tmp/xchg/coverage-data/bitrix_server_test.html http://${domain}/bitrix_server_test.php");
  '']

    ++ optional (versionAtLeast php.version "7") [''
      $dockerNode->execute("${
        wordpressScript {
          inherit pkgs;
          inherit domain;
        }
      }");
      $dockerNode->execute("${
        wrkScript {
          inherit pkgs;
          url = "http://${phpVersion}.ru/";
        }
      }");
    ''];
})
