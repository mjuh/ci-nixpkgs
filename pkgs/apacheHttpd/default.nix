{ stdenv, lib, fetchurl, apr, aprutil, perl, zlib, nss_ldap, nss_pam_ldapd, openldap, pcre, openssl, sslSupport ? true }:

stdenv.mkDerivation rec {
      version = "2.4.46";
      name = "apache-httpd-${version}";
      src = fetchurl {
          url = "mirror://apache/httpd/httpd-${version}.tar.bz2";
          sha256 = "1sj1rwgbcjgkzac3ybjy7j68c9b3dv3ap71m48mrjhf6w7vds3kl";
      };
      outputs = [ "out" "dev" ];
      setOutputFlags = false; # it would move $out/modules, etc.
      buildInputs = [ 
        perl zlib nss_ldap nss_pam_ldapd openldap 
      ] ++ lib.optional sslSupport openssl;
      prePatch = ''
          sed -i config.layout -e "s|installbuilddir:.*|installbuilddir: $dev/share/build|"
      '';

      preConfigure = ''
          configureFlags="$configureFlags --includedir=$dev/include"
      '';

      configureFlags = [
          "--with-apr=${apr.dev}"
          "--with-apr-util=${aprutil.dev}"
          "--with-z=${zlib.dev}"
          "--with-pcre=${pcre.dev}"
          "--disable-maintainer-mode"
          "--disable-debugger-mode"
          "--enable-mods-shared=all"
          "--enable-mpms-shared=all"
          "--enable-cern-meta"
          "--enable-imagemap"
          "--enable-cgi"
          "--disable-ldap"
          "--with-mpm=prefork"
          (lib.enableFeature sslSupport "ssl")
      ];

      enableParallelBuilding = true;
      stripDebugList = "lib modules bin";
      postInstall = ''
          mkdir -p $dev/bin
          mv $out/bin/apxs $dev/bin/apxs
      '';

      passthru = {
          inherit apr aprutil ;
      };
}
