{ php, image }:

# Test Docker containers as systemd units

let
  pkgs = <nixpkgs>;
  maketest = <nixpkgs/nixos/tests> + /make-test.nix;
  lib = <nixpkgs/lib>;

  wordpress = pkgs.fetchurl {
    url = https://downloads.wordpress.org/release/wordpress-5.2.2.tar.gz;
    sha256 = "08iilbvf1gam2nmacj0a8fgldnd2gighmslf9sny8dsdlqlwjgvq";
  };

  generic = { myphp, image, rootfs }:
    import maketest ({ pkgs, lib, ... }: {
      name = "apache2-" + myphp + "-default";
      nodes = {
        docker = { pkgs, ... }:
          {
            virtualisation =
              {
                memorySize = 4 * 1024;
                diskSize = 4 * 1024;
                docker.enable = true;
                dockerPreloader = {
                  images = [ image ];
                  qcowSize = 4 * 1024;
                };

              };

            boot.initrd.postMountCommands = ''
              for dir in apache2-${myphp}-default opcache home; do mkdir /mnt-root/$dir; done

              mkdir /mnt-root/apache2-${myphp}-default/sites-enabled

              cat <<EOF > /mnt-root/apache2-${myphp}-default/sites-enabled/5d41c60519f4690001176012.conf
              <VirtualHost 127.0.0.1:8056>
                  ServerName ${myphp}.ru
                  ServerAlias www.${myphp}.ru
                  ScriptAlias /cgi-bin /home/u12/${myphp}.ru/www/cgi-bin
                  DocumentRoot /home/u12/${myphp}.ru/www
                  <Directory /home/u12/${myphp}.ru/www>
                      Options +FollowSymLinks -MultiViews +Includes -ExecCGI
                      DirectoryIndex index.php index.html index.htm
                      Require all granted
                      AllowOverride all
                  </Directory>
                  AddDefaultCharset UTF-8
                UseCanonicalName Off
                  AddHandler server-parsed .shtml .shtm
                  php_admin_flag allow_url_fopen on
                  php_admin_value mbstring.func_overload 0
                  <IfModule mod_setenvif.c>
                      SetEnvIf X-Forwarded-Proto https HTTPS=on
                      SetEnvIf X-Forwarded-Proto https PORT=443
                  </IfModule>
                  <IfFile  /home/u12/logs>
                  CustomLog /home/u12/logs/www.${myphp}.ru-access.log common-time
                  ErrorLog /home/u12/logs/www.${myphp}.ru-error_log
                  </IfFile>
                  MaxClientsVHost 20
                  AssignUserID "#4165" "#4165"
              </VirtualHost>
              EOF

              mkdir -p /mnt-root/home/u12/${myphp}.ru/www

              cat <<EOF > /mnt-root/home/u12/${myphp}.ru/www/index.php
              <?php phpinfo(); ?>
              EOF

              chown 4165:4165 -R /mnt-root/home/u12

              cat <<EOF > /mnt-root/passwd
              root:x:0:0:root:/root:/bin/bash
              www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
              u12:x:4165:4165:Hosting account,,,,UnixAccount(id=12345678912345678912345a, accountId=123456, writable=True):/home/u12:/usr/sbin/nologin
              EOF

              cat <<EOF > /mnt-root/group
              root:x:0:
              www-data:x:33:
              u12:x:4165:
              EOF

              echo "127.0.0.1 docker-registry.intr" >> /mnt-root/etc/hosts

              for dir in /mnt-root/opt/postfix/spool/public /mnt-root/opt/postfix/spool/maildrop /mnt-root/opt/postfix/lib; do mkdir -p $dir ; done
        '';

            # From official nixpkgs Git repository:
            # nixos/modules/virtualisation/docker-containers.nix
            docker-containers.php = {
              image = "docker-registry.intr/webservices/apache2-${myphp}";
              extraDockerOptions = ["--network=host"
                                    "--cap-add" "SYS_ADMIN"
                                    "--mount" "readonly,source=/etc/passwd,target=/etc/passwd,type=bind"
                                    "--mount" "readonly,source=/etc/group,target=/etc/group,type=bind"
                                    "--mount" "source=/opcache,target=/opcache,type=bind"
                                    "--mount" "source=/home,target=/home,type=bind"
                                    "--mount" "source=/opt/postfix/spool/maildrop,target=/var/spool/postfix/maildrop,type=bind"
                                    "--mount" "source=/opt/postfix/spool/public,target=/var/spool/postfix/public,type=bind"
                                    "--mount" "source=/opt/postfix/lib,target=/var/lib/postfix,type=bind"
                                    "--mount" "target=/run,type=tmpfs"
                                    "--mount" "target=/tmp,type=tmpfs"
                                    "--mount"] 
              # XXX:
              ++ lib.optional true (lib.concatStrings ["readonly,source=/apache2-${myphp}-default,target=/read/sites-enabled,type=bind"]);

              # TODO: Use dockerArgHints.volumes
              # map (x:
              #       (array: lib.concatStringsSep ":" (lib.remove true array)) (lib.mapAttrsToList (name: value: value) x))
              #       dockerArgs.volumes;

              environment = {
                HTTPD_PORT = "8056";
                PHP_INI_SCAN_DIR = ":${rootfs}/etc/phpsec/default";
              };
            };
          };
      };

      testScript = ''
        startAll;

        my $wordpress = $docker->stateDir . "/www";
        system("mkdir -p $wordpress");
        system("tar -C $wordpress -xf ${wordpress}");

        my $log = $docker->succeed("ls -l $wordpress");
        print "\n\$ ls -l $wordpress\n";
        print "$log\n";

        # wait for docker-php.service to start
        $docker->waitForUnit("docker-php");

        $docker->waitUntilSucceeds("curl -s --head --header \"Host: ${myphp}.ru\" http://127.0.0.1:8056/phpinfo.php") =~ /200 OK/;

        $docker->shutdown;
      '';
    });

in

{
  php52 = generic { 
    myphp = "php52";
    image = image.php52-image;
    rootfs = ./php52-rootfs;
  };
  php53 = generic { 
    myphp = "php53";
    image = image.php53-image;
    rootfs = ./php53-rootfs;
  };
  php54 = generic { 
    myphp = "php54";
    image = image.php54-image;
    rootfs = ./php54-rootfs;
  };
  php55 = generic { 
    myphp = "php55";
    image = image.php55-image;
    rootfs = ./php55-rootfs;
  };
  php56 = generic { 
    myphp = "php56";
    image = image.php56-image;
    rootfs = ./php56-rootfs;
  };
  php70 = generic { 
    myphp = "php70";
    image = image.php70-image;
    rootfs = ./php70-rootfs;
  };
  php71 = generic { 
    myphp = "php71";
    image = image.php71-image;
    rootfs = ./php71-rootfs;
  };
  php72 = generic { 
    myphp = "php72";
    image = image.php72-image;
    rootfs = ./php72-rootfs;
  };
  php73 = generic { 
    myphp = "php73";
    image = image.php73-image;
    rootfs = ./php73-rootfs;
  };
}
