{ pkgs, debug ? false, bash, image, jq, lib, php, phpinfoCompare, rootfs, stdenv
, wordpress, wrk2, writeScript, python3, deepdiff, defaultTestSuite ? true
, containerStructureTestConfig }:

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

  runCurl = url: output:
    builtins.concatStringsSep " " [
      "curl"
      "--connect-timeout"
      "30"
      "--fail"
      "--silent"
      "--output"
      output
      url
    ];

  dockerNodeTest = import ./dockerNodeTest.nix;

  containerStructureTest = import ./scripts/container-structure-test.nix;

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
          images = [ image ] ++ map pkgs.dockerTools.pullImage [{
            imageName = "gcr.io/gcp-runtimes/container-structure-test";
            imageDigest =
              "sha256:cc5ff23f5c8d18e532664c6de2eab47e0d621b55b30ad47a1d4ee134220b3657";
            sha256 = "0m24qrlzarwwd5dpp6w6l38qr8wl4qcb0p67bmd0wigbzwxhhqm3";
            finalImageName = "gcr.io/gcp-runtimes/container-structure-test";
            finalImageTag = "latest";
          }];
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
    print "Tests entry point.\n";
    startAll;

    print "Start services.\n";
    $dockerNode->waitForUnit("mysql");
    $dockerNode->execute("${runDockerImage image}");
    $dockerNode->sleep(10);
  '']

    ++ optionals defaultTestSuite [
      (dockerNodeTest {
        description = "Copy phpinfo.";
        action = "execute";
        command = "cp -v ${phpinfo} /home/u12/${domain}/www/phpinfo.php";
      })
      (dockerNodeTest {
        description = "Fetch phpinfo.";
        action = "succeed";
        command = runCurl "http://${domain}/phpinfo.php"
          "/tmp/xchg/coverage-data/phpinfo.html";
      })
      (dockerNodeTest {
        description = "Fetch server-status.";
        action = "succeed";
        command = runCurl "http://127.0.0.1/server-status"
          "/tmp/xchg/coverage-data/server-status.html";
      })
      (dockerNodeTest {
        description = "Copy phpinfo-json.php.";
        action = "succeed";
        command = "cp -v ${
            ./phpinfo-json.php
          } /home/u12/${domain}/www/phpinfo-json.php";
      })
      (dockerNodeTest {
        description = "Fetch phpinfo-json.php.";
        action = "succeed";
        command = runCurl "http://${domain}/phpinfo-json.php"
          "/tmp/xchg/coverage-data/phpinfo.json";
      })
      (dockerNodeTest {
        description = "Run deepdiff against PHP on Upstart.";
        action = "succeed";
        command = testDiffPy {
          inherit pkgs;
          sampleJson = (./. + "/${phpVersion}.json");
          output = "/tmp/xchg/coverage-data/deepdiff.html";
        };
      })
      (dockerNodeTest {
        description = "Run deepdiff against PHP on Upstart with excludes.";
        action = "succeed";
        command = testDiffPy {
          inherit pkgs;
          sampleJson = (./. + "/${phpVersion}.json");
          output = "/tmp/xchg/coverage-data/deepdiff-with-excludes.html";
          excludes = import ./diff-to-skip.nix;
        };
      })
      (dockerNodeTest {
        description = "Run deepdiff against PHP on Nix.";
        action = "succeed";
        command = testDiffPy {
          inherit pkgs;
          sampleJson = (./. + "/web34/${phpVersion}.json");
          output = "/tmp/xchg/coverage-data/deepdiff-web34.html";
        };
      })
      (dockerNodeTest {
        description = "Run deepdiff against PHP on Nix with excludes.";
        action = "succeed";
        command = testDiffPy {
          inherit pkgs;
          sampleJson = (./. + "/web34/${phpVersion}.json");
          output = "/tmp/xchg/coverage-data/deepdiff-web34-with-excludes.html";
          excludes = import ./diff-to-skip.nix;
        };
      })
      (dockerNodeTest {
        description = "Copy bitrix_server_test.php.";
        action = "succeed";
        command = "cp -v ${
            ./bitrix_server_test.php
          } /home/u12/${domain}/www/bitrix_server_test.php";
      })
      (dockerNodeTest {
        description = "Run Bitrix test.";
        action = "succeed";
        command = runCurl "http://${domain}/bitrix_server_test.php"
          "/tmp/xchg/coverage-data/bitrix_server_test.html";
      })
      (dockerNodeTest {
        description = "Run container structure test.";
        action = "succeed";
        command = containerStructureTest {
          inherit pkgs;
          config = containerStructureTestConfig;
          image = image.imageName;
        };
      })
    ]

    ++ optionals (versionAtLeast php.version "7") [
      (dockerNodeTest {
        description = "Run WordPress test.";
        action = "succeed";
        command = wordpressScript {
          inherit pkgs;
          inherit domain;
        };
      })

      (dockerNodeTest {
        description = "Run wrk test.";
        action = "succeed";
        command = wrkScript {
          inherit pkgs;
          url = "http://${phpVersion}.ru/";
        };
      })
    ];
})
