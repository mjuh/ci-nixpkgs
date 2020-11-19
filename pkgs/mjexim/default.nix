{ stdenv, fetchurl, pkgconfig, coreutils, db, openssl, perl, pcre, libspf2, zlib, pam, hiredis, hiredis-vip }:

stdenv.mkDerivation rec {
  name = "exim";
  version = "4.93";

  src = fetchurl {
    urls = [
      "https://ftp.exim.org/pub/exim/exim4/old/${name}-${version}.tar.xz"
      "https://ftp.exim.org/pub/exim/exim4/${name}-${version}.tar.xz"
    ];
    sha256 = "10adbff685iv97qf2vvi58hz22vwxkq0v1l12h70p46mnl0k48b8";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ coreutils db openssl perl pcre libspf2 zlib pam hiredis hiredis-vip ];

  installFlags = [ "EXIM_PERL = perl.o" ];

  preBuild = ''
    		sed '
    		s:^\(BIN_DIRECTORY\)=.*:\1='"$out"'/bin:
    		s:^\(CONFIGURE_FILE\)=.*:\1=/etc/exim4/exim4.conf:
    		s:^\(EXIM_USER\)=.*:\1=ref\:mail:
    		s:^\(SPOOL_DIRECTORY\)=.*:\1=/exim-homeless-shelter:
    		s:^# \(TRANSPORT_LMTP\)=.*:\1=yes:
    		s:^# \(SUPPORT_MAILDIR\)=.*:\1=yes:
    		s:^EXIM_MONITOR=.*$:# &:
    		s:^\(FIXED_NEVER_USERS\)=root$:\1=0:
    		s:^# \(WITH_CONTENT_SCAN\)=.*:\1=yes:
    		s:^# \(AUTH_PLAINTEXT\)=.*:\1=yes:		
        s:^# \(EXPAND_LISTMATCH_RHS\)=.*:\1=yes:
    		s:^# \(EXIM_PERL\)=.*:\1=perl.o:	
    		s:^# \(SUPPORT_TLS\)=.*:\1=yes:
    		s:^# \(USE_OPENSSL\)=.*:\1=yes:
    		s:^# \(USE_OPENSSL_PC=openssl\)$:\1:
    		s:^# \(LOG_FILE_PATH=syslog\)$:\1:
    		s:^# \(HAVE_IPV6=yes\)$:\1:
    		s:^# \(CHOWN_COMMAND\)=.*:\1=${coreutils}/bin/chown:
    		s:^# \(CHGRP_COMMAND\)=.*:\1=${coreutils}/bin/chgrp:
    		s:^# \(CHMOD_COMMAND\)=.*:\1=${coreutils}/bin/chmod:
    		s:^# \(MV_COMMAND\)=.*:\1=${coreutils}/bin/mv:
    		s:^# \(RM_COMMAND\)=.*:\1=${coreutils}/bin/rm:
    		s:^# \(TOUCH_COMMAND\)=.*:\1=${coreutils}/bin/touch:
    		s:^# \(PERL_COMMAND\)=.*:\1=${perl}/bin/perl:
    		s:^# \(LOOKUP_REDIS=yes\)$:\1:
    		s:^\(LOOKUP_LIBS\)=\(.*\):\1=\2 -lhiredis -L${hiredis}/lib/hiredis -lssl -ldl -lm -lpthread -lz:
    		s:^# \(LOOKUP_LIBS\)=.*:\1=-lhiredis -L${hiredis}/lib/hiredis -lssl -ldl -lm -lpthread -lz:
    		s:^# \(LOOKUP_INCLUDE\)=.*:\1=-I${hiredis}/include/hiredis/:
    		s:^# \(AUTH_DOVECOT\)=.*:\1=yes:
    		s:^# \(SUPPORT_PAM\)=.*:\1=yes:
    		s:^\(EXTRALIBS_EXIM\)=\(.*\):\1=\2 -lpam:
    		s:^# \(EXTRALIBS_EXIM\)=.*:\1=-lpam:
    		s:^# \(SUPPORT_SPF\)=.*:\1=yes:
    		s:^# \(LDFLAGS += -lspf2\):\1:
    		#/^\s*#.*/d
    		#/^\s*$/d
    		' < src/EDITME > Local/Makefile
    	'';

  installPhase = ''
    mkdir -p $out/bin $out/share/man/man8
    cp doc/exim.8 $out/share/man/man8

    ( cd build-Linux-*
    cp exicyclog exim_checkaccess exim_dumpdb exim_lock exim_tidydb \
    	exipick exiqsumm exigrep exim_dbmbuild exim exim_fixdb eximstats \
    	exinext exiqgrep exiwhat \
    	$out/bin )

    ( cd $out/bin
    for i in mailq newaliases rmail rsmtp runq sendmail; do
    	ln -s exim $i
    done )
  '';
}
