{stdenv, fetchurl, db, openssl, cyrus_sasl, icu, libnsl, pcre,
lib, coreutils, findutils, gnugrep, gawk, gnused, makeWrapper, m4}:

stdenv.mkDerivation rec {
  pname = "postfix";
  version = "3.6.6";
  srcs = [
    (fetchurl {
    url = "http://cdn.postfix.johnriley.me/mirrors/postfix-release/official/${pname}-${version}.tar.gz";
    hash = "sha256-CYpxT0EEaO/ibiGR3I8xy6RQfVv0iPVvnrVUXjaG8NY=";
  })
    ./mj_rate_limit_lib
    ./mjpostdb
    ./conf
    ./db
  ];
  nativeBuildInputs = [ makeWrapper m4 ];
  buildInputs = [ db openssl cyrus_sasl icu libnsl pcre ];
  sourceRoot = "postfix-3.6.6";
  hardeningDisable = [ "format" ];
  hardeningEnable = [ "pie" ];
  patches = [
    ./patch/nix/postfix-script-shell.patch
    ./patch/nix/postfix-3.0-no-warnings.patch
    ./patch/nix/post-install-script.patch
    ./patch/nix/relative-symlinks.patch
    ./patch/mj/sendmail.patch
    ./patch/mj/postdrop.patch
    ./patch/mj/master.patch
    ./patch/mj/globalmake.patch
    ./patch/mj/makefile.patch
  ];
  ccargs = lib.concatStringsSep " " ([
    "-DUSE_TLS"
    "-DHAS_DB_BYPASS_MAKEDEFS_CHECK"
    "-DNO_IPV6"
    "-DNO_KQUEUE"
    "-DNO_NIS"
    "-DNO_DEVPOLL"
    "-DNO_EAI"
    "-DNO_PCRE"
  ]);
  auxlibs = lib.concatStringsSep " " (["-lresolv" "-lcrypto" "-lssl" "-ldb"]);
  preBuild = ''
    cp -r ../mj_rate_limit_lib/* src/global
    cp -r ../mjpostdb src
    chmod +w src/mjpostdb
    cp -rf ../conf/* conf
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
    mv -v installdir/$out/* $out/
    cp -rv installdir/etc $out
    cp bin/mjpostdb $out/bin
    cp conf/services $out/etc
    for each in ../db/*
    do
      db_load $out/etc/$(basename $each).db < $each
    done
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
