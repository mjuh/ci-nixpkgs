{ pkgs, firefox, debug ? false, bash, image, jq, lib 
, rootfs, stdenv, wordpress, wrk2, writeScript, python3
, containerStructureTestConfig, phpinfo, testDiffPy, wordpressScript, wrkScript
, dockerNodeTest, containerStructureTest, testImages, testSuite ? [ ], runCurl
, runDockerImage ? import ./scripts/runDockerImage.nix, runApacheContainer ?
  runDockerImage {
    inherit pkgs;
    inherit image;
  } }:

# Run virtual machine, then container with Apache and PHP, and test it.

with lib;

let
  maketest = <nixpkgs/nixos/tests> + /make-test.nix;
  domain = "perl518.ru";

  pullContainers = writeScript "pullContainers.sh" ''
    #!/bin/sh -eux
    ${builtins.concatStringsSep "; "
    (map (container: "${pkgs.docker}/bin/docker load --input ${container}")
      ([ image ] ++ map pkgs.dockerTools.pullImage testImages))}
  '';

in import maketest ({ pkgs, lib, ... }: {
  name = lib.concatStringsSep "-" [ "apache2" "perl518" ];
  nodes = {
    dockerNode = { pkgs, ... }: {
      virtualisation = {
        cores = 3;
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
      networking.extraHosts = "127.0.0.1 ${domain} www.${domain}";
      users.users = {
        u12 = {
          isNormalUser = true;
          description = "Test user";
          password = "foobar";
          uid = 1001;
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
        "/etc/apache2-perl518/sites-enabled";
      environment.variables.SOCKET_HTTP_PORT = "80";
      environment.interactiveShellInit = ''
        alias ll='ls -alF'
        alias s='sudo -i'
      '';
      systemd.services.docker.postStart = ''
      mkdir -p /etc/apache2-perl518/sites-enabled /opt/postfix/spool/{maildrop,public}  /opt/postfix/lib  /home/u12/perl518.ru/{www,logs} 
  cat <<EOF > /etc/apache2-perl518/sites-enabled/${domain}.conf
    <VirtualHost 127.0.0.1:80>
    ServerName ${domain}
    ServerAlias www.${domain}
    ScriptAlias /cgi-bin /home/u12/${domain}/www/cgi-bin
    DocumentRoot /home/u12/${domain}/www
    <Directory /home/u12/${domain}/www>
        Options +FollowSymLinks -MultiViews -Includes +ExecCGI
        DirectoryIndex index.php index.html index.htm
        Require all granted
        AllowOverride all
    </Directory>
    AddDefaultCharset windows-1251
    UseCanonicalName Off
    AddHandler cgi-script .cgi .pl
    UseCanonicalName Off
    <IfModule mod_setenvif.c>
        SetEnvIf X-Forwarded-Proto https HTTPS=on
        SetEnvIf X-Forwarded-Proto https PORT=443
    </IfModule>
      <IfFile  /home/u12/logs>
      CustomLog /home/u12/logs/www.${domain}-access.log common-time
      ErrorLog /home/u12/logs/www.${domain}-error_log
      </IfFile>
    MaxClientsVHost 20
    AssignUserID #1001 #1001
   </VirtualHost>
  EOF
      docker container prune -f  >/dev/null || true
      export SECURITY_LEVEL="default";
      export SITES_CONF_PATH="/etc/apache2-perl518/sites-enabled";
      export SOCKET_HTTP_PORT="80";
          mkdir -p /opt/run
          ${builtins.concatStringsSep "; "
            (map (container: "${pkgs.docker}/bin/docker load --input ${container}")
              ([ image ] ++ map pkgs.dockerTools.pullImage testImages))}
          ${pkgs.netcat-gnu}/bin/nc -zvv 127.0.0.1 $SOCKET_HTTP_PORT || ${runApacheContainer}
          until [[ $(${pkgs.curl}/bin/curl -f -I -L -s -o /dev/null -w %{http_code} http://127.0.0.1/server-status) -eq 200 ]] ; do sleep 1 ; done
      '';
    };
  };

  testScript = [''
    print "Tests entry point.\n";
    startAll;
    print "Start services.\n";
    $dockerNode->waitForUnit("docker");
  '']
    ++ testSuite;
})
