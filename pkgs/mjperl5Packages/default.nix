{ lib, stdenv, perl, perlPackages, buildPerlPackage, fetchurl,
  pkgconfig, config, pkgs, fetchFromGitHub, gnused  }:

let

  perl5lib = buildPerlPackage rec {
    pname = "perl5lib";
    version = "1.02";
    src = fetchurl {
      url = "mirror://cpan/authors/id/N/NO/NOBULL/${pname + "-" +version}.tar.gz";
      sha256 = "24b96925840153c444241398b36fc8976e085fdb0d879c91734709cf917eceac";
    };
  };

  IOStty = perlPackages.buildPerlModule rec {
    pname = "IO-Stty";
    version = "0.03";
    src = fetchurl {
      url = "mirror://cpan/authors/id/T/TO/TODDR/${pname + "-" +version}.tar.gz";
      sha256 = "6929528db85e89d23a9761f400b5b6555ad5a9eba5208b65992399c8bd809152";
    };
    buildInputs = [ perlPackages.ModuleBuild ];
  };

  TextTruncate = buildPerlPackage rec {
    pname = "Text-Truncate";
    version = "1.06";
    src = fetchurl {
      url = "mirror://cpan/authors/id/I/IL/ILV/${pname + "-" +version}.tar.gz";
      sha256 = "1933361ec297253d1dd518068b863dcda131aba1da5ac887040c3d85a2d2a5d2";
    };
    buildInputs = [ perlPackages.ModuleBuild ];
  };

  MIMEBase64 = buildPerlPackage rec {
    pname = "MIME-Base64";
    version = "3.15";
    src = fetchurl {
      url = "mirror://cpan/authors/id/G/GA/GAAS/${pname + "-" +version}.tar.gz";
      sha256 = "7f863566a6a9cb93eda93beadb77d9aa04b9304d769cea3bb921b9a91b3a1eb9";
    };
  };

  OpenOfficeOODoc = buildPerlPackage rec {
    pname = "OpenOffice-OODoc";
    version = "2.125";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JM/JMGDOC/${pname + "-" +version}.tar.gz";
      sha256 = "c11448970693c42a8b9e93da48cac913516ce33a9d44a6468400f7ad8791dab6";
    };
    propagatedBuildInputs = [ perlPackages.ArchiveZip perlPackages.XMLTwig ];
  };

  TemplateToolkit = buildPerlPackage rec {
    pname = "Template-Toolkit";
    version = "2.29";
    src = fetchurl {
      url = "mirror://cpan/authors/id/A/AT/ATOOMIC/${pname + "-" +version}.tar.gz";
      sha256 = "2bddd71cf41fb805fd5234780daf53226b8e7004c623e1647ba2658113614779";
    };
    buildInputs = [ perlPackages.CGI perlPackages.TestLeakTrace ];
    propagatedBuildInputs = [ perlPackages.AppConfig ];
  };

  URIEscape = buildPerlPackage rec {
    pname = "URI-Escape";
    version = "1.76";
    src = fetchurl {
      url = "mirror://cpan/authors/id/O/OA/OALDERS/URI-${version}.tar.gz";
      sha256 = "0gj1aj18k43kmzc3y1zhj5giinf8rksacf757r475xfna0fqxjdj";
    };
    buildInputs = [ perlPackages.TestNeeds ];
  };

  perls = {
    perl5lib = perl5lib;
    mod_perl2 = perlPackages.mod_perl2;
    ArchiveZip = perlPackages.ArchiveZip;
    TextTruncate = TextTruncate;
    MIMEBase64 = MIMEBase64;
    TemplateToolkit = TemplateToolkit;
    OpenOfficeOODoc = OpenOfficeOODoc;
    IOStty = IOStty;
    CarpAlways = perlPackages.CarpAlways;
    CarpAssertMore = perlPackages.CarpAssertMore;
    CarpAssert = perlPackages.CarpAssert;
    CarpClan = perlPackages.CarpClan;
    DataDumper = perlPackages.DataDumper;
    FileCopyRecursive = perlPackages.FileCopyRecursive;
    FileCopyRecursiveReduced = perlPackages.FileCopyRecursiveReduced;
    HTMLTemplate = perlPackages.HTMLTemplate;
    ImageInfo = perlPackages.ImageInfo;
    MIMELite = perlPackages.MIMELite;
    SpreadsheetParseExcel = perlPackages.SpreadsheetParseExcel;
    SpreadsheetWriteExcel = perlPackages.SpreadsheetWriteExcel;
    TextIconv = perlPackages.TextIconv;
    FCGI = perlPackages.FCGI;
    FCGIProcManager = perlPackages.FCGIProcManager;
    XMLSimple = perlPackages.XMLSimple;
    ApacheTest = perlPackages.ApacheTest;
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
    HTTPMessage = perlPackages.HTTPMessage;
    HTMLParser = perlPackages.HTMLParser;
    HTTPDate = perlPackages.HTTPDate;
    TryTiny = perlPackages.TryTiny;
    inherit URIEscape;
    perl = perlPackages.perl;
    TypesSerialiser = perlPackages.TypesSerialiser;
    XMLLibXML = perlPackages.XMLLibXML;
    XMLSAX = perlPackages.XMLSAX;
    XMLSAXBase = perlPackages.XMLSAXBase;
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
        substituteInPlace ./perl_modules_modperl.conf --subst-var perl5lib
        substituteInPlace ./environment --subst-var perl5lib
      '';
      installPhase = ''
         mkdir -p $out/etc/
         cp -pr ./ $out/
         cp -pr ./environment $out/etc/
      '';
    };
  };
}
