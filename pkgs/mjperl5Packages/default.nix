{ stdenv, perl, perlPackages, buildPerlPackage, fetchurl, pkgconfig,
  config, pkgs, fetchFromGitHub, gnused }:

let

  TextTruncate = buildPerlPackage rec {
    name = "Text-Truncate-1.06";
    src = fetchurl {
      url = "mirror://cpan/authors/id/I/IL/ILV/${name}.tar.gz";
      sha256 = "1933361ec297253d1dd518068b863dcda131aba1da5ac887040c3d85a2d2a5d2";
    };
    buildInputs = [ perlPackages.ModuleBuild ];
  };

  perl5Packages = [
    TextTruncate
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

in

{
  mjPerlPackages = {
    mjPerlModules = stdenv.mkDerivation rec {
      name = "mjperl";
      nativeBuildInputs = [ perl ] ++ perl5Packages ;
      perl5lib = perlPackages.makePerlPath perl5Packages;
      src = ./perlmodules;

      buildPhase = ''
        export perl5lib="${perl5lib}"
        echo ${perl5lib}
        substituteInPlace ./perl_modules.conf --subst-var perl5lib
      '';
      installPhase = ''
         cp -pr ./ $out/
      '';
    };
    TextTruncate = TextTruncate;
    TimeLocal = perlPackages.TimeLocal;
    PerlMagick = perlPackages.PerlMagick;
    commonsense = perlPackages.commonsense;
    Mojolicious = perlPackages.Mojolicious;
    base = perlPackages.base;
    libxml_perl = perlPackages.libxml_perl;
    libnet = perlPackages.libnet;
    libintl_perl = perlPackages.libintl_perl;
    LWP = perlPackages.LWP;
    ListMoreUtilsXS = perlPackages.ListMoreUtilsXS;
    LWPProtocolHttps = perlPackages.LWPProtocolHttps;
    DBI = perlPackages.DBI;
    DBDmysql = perlPackages.DBDmysql;
    CGI = perlPackages.CGI;
    FilePath = perlPackages.FilePath;
    DigestPerlMD5 = perlPackages.DigestPerlMD5;
    DigestSHA1 = perlPackages.DigestSHA1;
    FileBOM = perlPackages.FileBOM;
    GD = perlPackages.GD;
    LocaleGettext = perlPackages.LocaleGettext;
    HashDiff = perlPackages.HashDiff;
    JSONXS = perlPackages.JSONXS;
    POSIXstrftimeCompiler = perlPackages.POSIXstrftimeCompiler;
    perl = perlPackages.perl;
  };
}

