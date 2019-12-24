{ phpVersion }:

let domain = phpVersion + ".ru";
in ''
  for dir in /apache2-${phpVersion}-default /opcache /home \
             /opt/postfix/spool/public /opt/postfix/spool/maildrop \
             /opt/postfix/lib; do
      mkdir -p /mnt-root$dir
  done

  mkdir /mnt-root/apache2-${phpVersion}-default/sites-enabled

  # Used as Docker volume
  #
  mkdir -p /mnt-root/opt/etc
  for file in group gshadow passwd shadow; do
    mkdir -p /mnt-root/opt/etc
    cp -v /etc/$file /mnt-root/opt/etc/$file
  done
  #
  mkdir -p /mnt-root/opcache
  chmod 1777 /mnt-root/opcache

  mkdir -p /mnt-root/etc/apache2-${phpVersion}-default/sites-enabled/
  cat <<EOF > /mnt-root/etc/apache2-${phpVersion}-default/sites-enabled/5d41c60519f4690001176012.conf
  <VirtualHost 127.0.0.1:80>
      ServerName ${domain}
      ServerAlias www.${domain}
      ScriptAlias /cgi-bin /home/u12/${domain}/www/cgi-bin
      DocumentRoot /home/u12/${domain}/www
      <Directory /home/u12/${domain}/www>
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
      php_admin_value opcache.file_cache "/opcache/${domain}"
      <IfModule mod_setenvif.c>
          SetEnvIf X-Forwarded-Proto https HTTPS=on
          SetEnvIf X-Forwarded-Proto https PORT=443
      </IfModule>
      <IfFile  /home/u12/logs>
      CustomLog /home/u12/logs/www.${domain}-access.log common-time
      ErrorLog /home/u12/logs/www.${domain}-error_log
      </IfFile>
      MaxClientsVHost 20
      AssignUserID #4165 #4165
  </VirtualHost>
  EOF

  mkdir -p /mnt-root/home/u12/${domain}/www
''
