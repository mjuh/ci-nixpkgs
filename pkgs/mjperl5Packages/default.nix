{ lib, stdenv, perl, perlPackages }:

let
# add new modules at ./nixpkgs/pkgs/top-level/perl-packages.nix
 perls = {
    RTFWriter = perlPackages.RTFWriter;
    URIEscape = perlPackages.URIEscape;
    perl5lib = perlPackages.Perl5lib;
    mod_perl2 = perlPackages.mod_perl2;
    TestTester = perlPackages.TestTester;
    ArchiveZip = perlPackages.ArchiveZip;
    EncodeLocale = perlPackages.EncodeLocale;
    TextTruncate = perlPackages.TextTruncate;
    MIMEBase64 = perlPackages.MIMEBase64;
    TemplateToolkit = perlPackages.TemplateToolkit;
    OpenOfficeOODoc = perlPackages.OpenOfficeOODoc;
    IOStty = perlPackages.IOStty;
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
