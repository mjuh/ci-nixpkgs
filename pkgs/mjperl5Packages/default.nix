{ stdenv, perl, perlPackages, buildPerlPackage, fetchurl, pkgconfig,
  config, pkgs, fetchFromGitHub, gnused }:

with import <nixpkgs> {};

let

  TextTruncate = buildPerlPackage rec {
    name = "Text-Truncate-1.06";
    src = fetchurl {
      url = "mirror://cpan/authors/id/I/IL/ILV/${name}.tar.gz";
      sha256 = "1933361ec297253d1dd518068b863dcda131aba1da5ac887040c3d85a2d2a5d2";
    };
    buildInputs = [ perlPackages.ModuleBuild ];
  };

  perls = {
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

  perls-drv = lib.attrValues perls;

in

{
  mjPerlPackages = {
    inherit perls;
    mjPerlModules = stdenv.mkDerivation rec {
      name = "mjperl";
      nativeBuildInputs = [ perl ] ++ perls-drv ;
      perl5lib = perlPackages.makePerlPath perls-drv;
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
  };
}
