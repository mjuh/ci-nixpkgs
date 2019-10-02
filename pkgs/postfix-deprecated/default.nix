{ stdenv, fetchurl, db, glibc, openssl,
  coreutils, findutils, gnused, gnugrep, bison, perl
}:

assert stdenv.isLinux;

stdenv.mkDerivation rec {
  name = "postfix-2.8.12";

  src = fetchurl {
    url = "ftp://ftp.cs.uu.nl/mirror/postfix/postfix-release/official/${name}.tar.gz";
    sha256 = "11z07mjy53l1fnl7k4101yk4ilibgqr1164628mqcbmmr8bh2szl";
  };

  buildInputs = [db openssl bison perl];

  patches = [
    ./postfix-2.2.9-db.patch
    ./postfix-2.2.9-lib.patch
    ./db-linux3.patch
    ./postfix-script-shell.patch
    ./0001-up.patch
    ./0001-5.patch
    ./0001-sys5.patch
  ];

  postPatch = ''
    sed -i -e s,/usr/bin,/var/run/current-system/sw/bin, \
      -e s,/usr/sbin,/var/run/current-system/sw/bin, \
      -e s,:/sbin,, src/util/sys_defs.h
  '';

  hardeningDisable = [ "format" ];

  preConfigure = ''
    rm -rf src/smtpd
    sed -i 's|src/smtpd||' ./Makefile.in
    sed -i 's|man8/smtpd.8||' ./man/Makefile.in
    sed -i 's|smtpd.8.html||' ./html/Makefile.in

    rm -rf src/smtp
    sed -i 's|src/smtp||' ./Makefile.in
    sed -i 's|man8/smtp.8||' ./man/Makefile.in
    sed -i 's|smtp.8.html||' ./html/Makefile.in

    sed -i 's|\sstone||' ./Makefile.in

    rm -rf src/dnsblog
    sed -i 's|src/dnsblog||' ./Makefile.in
    sed -i 's|man8/dnsblog.8||' ./man/Makefile.in
    sed -i 's|dnsblog.8.html||' ./html/Makefile.in
  '';

  preBuild = ''
    export daemon_directory=$out/libexec/postfix
    export command_directory=$out/sbin
    export queue_directory=/var/spool/postfix
    export sendmail_path=$out/bin/sendmail
    export mailq_path=$out/bin/mailq
    export newaliases_path=$out/bin/newaliases
    export html_directory=$out/share/postfix/doc/html
    export manpage_directory=$out/share/man
    export sample_directory=$out/share/postfix/doc/samples
    export readme_directory=$out/share/postfix/doc

    chmod +x ./makedefs
    make makefiles CCARGS='-fPIE -fstack-protector-all --param ssp-buffer-size=4 -O2 -D_FORTIFY_SOURCE=2' AUXLIBS='-lssl -lcrypto -ldb -lnsl -pie -Wl,-z,relro,-z,now'
  '';

  postBuild = ''
    touch libexec/dnsblog
    touch libexec/smtpd
    touch libexec/smtp
  '';

  installPhase = ''
    sed -e '/^PATH=/d' -i postfix-install
    $SHELL postfix-install install_root=out -non-interactive -package

    mkdir -p $out
    mv -v "out$out/"* $out/

    mkdir -p $out/share/postfix
    mv conf $out/share/postfix/
    mv LICENSE TLS_LICENSE $out/share/postfix/

    sed -e 's@^PATH=.*@PATH=${coreutils}/bin:${findutils}/bin:${gnused}/bin:${gnugrep}/bin:'$out'/sbin@' -i $out/share/postfix/conf/post-install $out/libexec/postfix/post-install
    sed -e '2aPATH=${coreutils}/bin:${findutils}/bin:${gnused}/bin:${gnugrep}/bin:'$out'/sbin' -i $out/share/postfix/conf/postfix-script $out/libexec/postfix/postfix-script
    chmod a+x $out/share/postfix/conf/{postfix-script,post-install}
  '';

  inherit glibc;

  meta = {
    homepage = "http://www.postfix.org/";
    description = "a fast, easy to administer, and secure mail server";
    license = stdenv.lib.licenses.bsdOriginal;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.simons ];
  };
}
