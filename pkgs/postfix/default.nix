{ stdenv, fetchurl, wrapProgram, db, openssl, cyrus_sasl, icu, libnsl, pcre }:

stdenv.mkDerivation rec {
      name = "postfix-${version}";
      version = "3.4.5";
      srcs = [
         ( fetchurl {
            url = "ftp://ftp.cs.uu.nl/mirror/postfix/postfix-release/official/${name}.tar.gz";
            sha256 = "17riwr21i9p1h17wpagfiwkpx9bbx7dy4gpdl219a11akm7saawb";
          })
       ./patch/postfix/mj/lib
      ];
      nativeBuildInputs = [ makeWrapper m4 ];
      buildInputs = [ db openssl cyrus_sasl icu libnsl pcre ];
      sourceRoot = "postfix-3.4.5";
      hardeningDisable = [ "format" ];
      hardeningEnable = [ "pie" ];
      patches = [
       ./patch/postfix/nix/postfix-script-shell.patch
       ./patch/postfix/nix/postfix-3.0-no-warnings.patch
       ./patch/postfix/nix/post-install-script.patch
       ./patch/postfix/nix/relative-symlinks.patch
       ./patch/postfix/mj/sendmail.patch
       ./patch/postfix/mj/postdrop.patch
       ./patch/postfix/mj/globalmake.patch
      ];
       ccargs = lib.concatStringsSep " " ([
          "-DUSE_TLS"
          "-DHAS_DB_BYPASS_MAKEDEFS_CHECK"
          "-DNO_IPV6"
          "-DNO_KQUEUE" "-DNO_NIS" "-DNO_DEVPOLL" "-DNO_EAI" "-DNO_PCRE"
       ]);

       auxlibs = lib.concatStringsSep " " ([
           "-lresolv" "-lcrypto" "-lssl" "-ldb"
       ]);
      preBuild = ''
          cp -pr ../lib/* src/global
          sed -e '/^PATH=/d' -i postfix-install
          sed -e "s|@PACKAGE@|$out|" -i conf/post-install

          # post-install need skip permissions check/set on all symlinks following to /nix/store
          sed -e "s|@NIX_STORE@|$NIX_STORE|" -i conf/post-install

          export command_directory=$out/sbin
          export config_directory=/etc/postfix
          export meta_directory=$out/etc/postfix
          export daemon_directory=$out/libexec/postfix
          export data_directory=/var/lib/postfix
          export html_directory=$out/share/postfix/doc/html
          export mailq_path=$out/bin/mailq
          export manpage_directory=$out/share/man
          export newaliases_path=$out/bin/newaliases
          export queue_directory=/var/spool/postfix
          export readme_directory=$out/share/postfix/doc
          export sendmail_path=$out/bin/sendmail
          make makefiles CCARGS='${ccargs}' AUXLIBS='${auxlibs}'
      '';

      installTargets = [ "non-interactive-package" ];
      installFlags = [ "install_root=installdir" ];

      postInstall = ''
          mkdir -p $out
          cat << EOF > installdir/etc/postfix/main.cf
          mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
          mailbox_size_limit = 0
          recipient_delimiter = +
          message_size_limit = 20480000
          maillog_file = /dev/stdout
          relayhost = mail-checker2.intr
          EOF
          echo "smtp            25/tcp          mail" >> installdir/etc/services
          echo "postlog   unix-dgram n  -       n       -       1       postlogd" >> installdir/etc/postfix/master.cf
          echo "*: /dev/null" >> installdir/etc/aliases
          mv -v installdir/$out/* $out/
          cp -rv installdir/etc $out
          sed -e '/^PATH=/d' -i $out/libexec/postfix/post-install
          wrapProgram $out/libexec/postfix/post-install \
            --prefix PATH ":" ${lib.makeBinPath [ coreutils findutils gnugrep ]}
          wrapProgram $out/libexec/postfix/postfix-script \
            --prefix PATH ":" ${lib.makeBinPath [ coreutils findutils gnugrep gawk gnused ]}
          rm -f $out/libexec/postfix/post-install \
                $out/libexec/postfix/postfix-wrapper \
                $out/libexec/postfix/postfix-script \
                $out/libexec/postfix/.post-install-wrapped \
                $out/libexec/postfix/postfix-tls-script \
                $out/libexec/postfix/postmulti-script \
                $out/libexec/postfix/.postfix-script-wrapped
      '';
  }
