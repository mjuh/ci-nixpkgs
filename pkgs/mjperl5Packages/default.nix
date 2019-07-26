{ stdenv, perl }:
stdenv.mkDerivation rec {
      name = "mjperl";
      perl5Packages = [
         perlPackages.TimeLocal
         perlPackages.PerlMagick
         perlPackages.commonsense
         perlPackages.Mojolicious
         perlPackages.base
         perlPackages.libxml_perl
         perlPackages.libnet
         perlPackages.libintl_perl
         perlPackages.LWP
         perlPackages.ListMoreUtilsXS
         perlPackages.LWPProtocolHttps
         perlPackages.DBI
         perlPackages.DBDmysql
         perlPackages.CGI
         perlPackages.FilePath
         perlPackages.DigestPerlMD5
         perlPackages.DigestSHA1
         perlPackages.FileBOM
         perlPackages.GD
         perlPackages.LocaleGettext
         perlPackages.HashDiff
         perlPackages.JSONXS
         perlPackages.POSIXstrftimeCompiler
         perlPackages.perl
      ];
      nativeBuildInputs = [  ] ++ perl5Packages ;
      perl5lib = perlPackages.makePerlPath perl5Packages;
      src = ./perlmodules;
      buildPhase = ''
        export perl5lib="${perl5lib}"
        echo ${perl5lib}
        substituteAllInPlace $src/perl_modules.conf
      '';
      installPhase = ''
         cp -pr ${src} $out/
      '';
  }

