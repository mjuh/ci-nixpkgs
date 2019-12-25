{ pkgs, firefox, debug ? false, bash, image, jq, lib, php, phpinfoCompare
, rootfs, stdenv, wordpress, wrk2, writeScript, python3, deepdiff
, defaultTestSuite ? true, containerStructureTestConfig, phpinfo, testDiffPy
, wordpressScript, wrkScript, dockerNodeTest, containerStructureTest
, testImages, testSuite ? [ ], runCurl }:

# Run virtual machine, then container with Apache and PHP, and test it.

with lib;

let
  maketest = <nixpkgs/nixos/tests> + /make-test.nix;

  runDockerImage = import ./scripts/runDockerImage.nix;

  php2version = php:
    "php" + lib.versions.major php.version + lib.versions.minor php.version;

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

      networking.extraHosts = "127.0.0.1 ${domain}";
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
          openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC35V1L3xgGA7DIdUCRzLpOjeaUi+qt2Gb5DV67ifmyw5i7UH9onVen6FQKMkuQBn0hVu9h9XVV30lGtCXj7Des/FXpV9OW3MRbWKxmekDshZHu+QkhZer9i+Nd413Q+UDzJGANUwJ71mr3H3rqTDZnWN/LQGkGv8xR/mK4vWfAWgidi1sdABgoEh0gN80Oa2VMhsX0Nx2VmCv5k7mftajADKnTc6paZGzCaShNgTlExZEHRfUUqXb1Yk3gifIZNxhdbcplmRLeMccbYnv0i7cg8TekH+3VmeS+JWNYVHrxHuic/L9otSL7HXnmnlAawmMQLZPUTCIMQP4kWju7I0BGCC2tUpm8OZvxtXtbHjLk5oX+Oe66IV142ORwvH/mWnOWs9JeafcGpP1VerpBTmPeQi3flbKOGCAGCeQtnLO8XPIx6FzNAfzrJJX05tvzo5Hau9ukDwLEzk+0+fb1biJOqbYFdwoj/mFBIwKLzAoOGw2v7UZmLAzPUFaKiZki4NgRpq5Myrc1xcn39h5jjMZU1K29lVxbMjYE3ikHrUOEYCsPQwL5KEKVIQRqk6UZY4FxApeSgoiCftbWGXpjheCHOUyd9+MtlL/Q1aWbxkMT5eNmFvMVm7hfLZqXje0lAnJJOX+KgyoHnNqmAmZsauUreW/mfhTFHFTCG8wpW50s3w==" ];
        };
      };

      security.sudo.enable = true;
      security.sudo.extraConfig = ''
         admin  ALL=NOPASSWD: ALL
      '';

      services.openssh.enable = if debug then true else false;
      services.openssh.permitRootLogin = if debug then "yes" else "no";
      environment.systemPackages = with pkgs; [ rsync mc tree jq ];
    
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
      boot.initrd.postMountCommands =
        import ./boot-initrd-postMountCommands.nix { inherit phpVersion; };

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
    };
  };

  testScript = [''
    print "Tests entry point.\n";
    startAll;

    print "Start services.\n";
    $dockerNode->waitForUnit("mysql");
    $dockerNode->execute("${runDockerImage { inherit pkgs; inherit image; }}");
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
      (dockerNodeTest {
        description = "Run mariadb connector test.";
        action = "succeed";
        command = "${testPhpMariadbConnector}";
        # TODO: Run test in container, e.g: docker exec apache2-php73-default /opt/php73/bin/php -r '$mysqlnd = function_exists("mysqli_fetch_all"); if ($mysqlnd) {echo "mysqlnd enabled";} else {echo "No";}'

      })
    ]

    ++ testSuite

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
        description = "Take WordPress screenshot";
        action = "succeed";
        command = builtins.concatStringsSep " " [
          "${firefox}/bin/firefox"
          "--headless"
          "--screenshot=/tmp/xchg/coverage-data/wordpress.png"
          "http://${domain}/"
        ];
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
