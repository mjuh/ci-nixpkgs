{ pkgs, lib, stdenv, perl, perlPackages }:

# TODO:
#
# Failed to find: 'WPUserAgentDetermined' , 'Webinject',
# 'UnicodeUTF8', , 'UnicodeMap', 'TextASCIITable' 2'TermSize',
# 'ScalarUtilNumeric' , 'RPCXML' , 'Quota', 'NetIPv6Addr', ,
# 'NetIPv4Addr' 'NetCUPS', 'AlgorithmDiffXS' 'ApacheReload'
# 'DateCalcXS', , 'YAMLSyck' 'DigestBubbleBabble' 'Dpkg', 'Filechmod',
# 'FileFcntlLock', 'HTMLFormat', 'HTMLTemplatePro', 'IOSocketINET6', ,
# 'libwwwperl', 'libxmlperl', 'YAMLAppConfig' , 'MIMEBase32'
# 'mimetypes', 'NagiosPlugin',
#
# Failing test: 'NetAddrIP', 'DataValidateIP'.

rec {
  perlsNonWeb = {
    UnixPID = perlPackages.UnixPID;
    Expect = perlPackages.Expect;
    ProcBackground = perlPackages.ProcBackground;
  };

  # add new modules at ./nixpkgs/pkgs/top-level/perl-packages.nix
  perls = {
    perl5lib = perlPackages.Perl5lib;

    # Propagates gcc
    # mod_perl2 = perlPackages.mod_perl2;

    # AlgorithmDiffXS
    # ApacheReload
    # DataValidateIP = perlPackages.DataValidateIP;
    # DateCalcXS = perlPackages.DateCalcXS;
    # DigestBubbleBabble = DigestBubbleBabble;
    # Dpkg = perlPackages.Dpkg;
    # Filechmod = perlPackages.Filechmod;
    # FileFcntlLock = perlPackages.FileFcntlLock;
    # HTMLFormat = perlPackages.HTMLFormat;
    # HTMLTemplatePro = perlPackages.HTMLTemplatePro;
    # IOSocketINET6 = perlPackages.IOSocketINET6;
    # libwwwperl = perlPackages.libwwwperl;
    # libxmlperl = perlPackages.libxmlperl;
    # MIMEBase32 = perlPackages.MIMEBase32;
    # mimetypes = perlPackages.mimetypes;
    # NagiosPlugin = perlPackages.NagiosPlugin;
    # NetAddrIP = perlPackages.NetAddrIP;
    # NetCUPS = perlPackages.NetCUPS;
    # NetIPv4Addr = perlPackages.NetIPv4Addr;
    # NetIPv6Addr = perlPackages.NetIPv6Addr;
    # Quota = perlPackages.Quota;
    # RPCXML = perlPackages.RPCXML;
    # ScalarUtilNumeric = perlPackages.ScalarUtilNumeric;
    # TermSize = perlPackages.TermSize;
    # TextASCIITable = perlPackages.TextASCIITable;
    # UnicodeMap = perlPackages.UnicodeMap;
    # UnicodeUTF8 = perlPackages.UnicodeUTF8;
    # Webinject = perlPackages.Webinject;
    # WPUserAgentDetermined = perlPackages.WPUserAgentDetermined;
    # YAMLAppConfig = perlPackages.YAMLAppConfig;
    # YAMLSyck = perlPackages.YAMLSyck;

    inherit (perlPackages)
      AlgorithmDiff
      AlgorithmMerge
      ApacheTest
      ArchiveExtract
      ArchiveZip
      AuthenSASL
      base
      BitVector
      BSDResource
      CacheMemcached
      Carp
      CarpAlways
      CarpAssert
      CarpAssertMore
      CarpClan
      CGI
      ClassAccessor
      ClassDataInheritable
      ClassFactoryUtil
      ClassLoad
      ClassLoadXS
      ClassSingleton
      commonsense
      ConfigIniFiles
      ConfigTiny
      CryptRC4
      CryptSSLeay
      DataDumper
      DataOptList
      DateCalc
      DateManip
      DateTime
      DateTimeFormatBuilder
      DateTimeFormatISO8601
      DateTimeLocale
      DBDmysql
      DBFile
      DBI
      DevelStackTrace
      DevelSymdump
      DigestHMAC
      DigestPerlMD5
      DigestSHA1
      EmailDateFormat
      EncodeLocale
      EvalClosure
      ExceptionClass
      FCGI
      FCGIProcManager
      FileBOM
      FileCopyRecursive
      FileCopyRecursiveReduced
      FileListing
      FilePath
      FilePid
      FontAFM
      GD
      HashDiff
      HTMLForm
      HTMLParser
      HTMLTagset
      HTMLTemplate
      HTMLTree
      HTTPCookies
      HTTPDaemon
      HTTPDate
      HTTPMessage
      HTTPNegotiate
      ImageInfo
      ImageSize
      IOHTML
      IOSocketSSL
      IOString
      IOstringy
      IOStty
      IPCRun
      JSON
      JSONXS
      libintl_perl
      libnet
      libxml_perl
      ListAllUtils
      ListMoreUtils
      ListMoreUtilsXS
      LocaleGettext
      LogMessageSimple
      LWP
      LWPMediaTypes
      LWPProtocolhttps
      LWPProtocolHttps
      MailIMAPClient
      MailTools
      MathCalcUnits
      MIMEBase64
      MIMELite
      ModuleImplementation
      ModulePluggable
      ModuleRuntime
      Mojolicious
      MROCompat
      namespaceautoclean
      namespaceclean
      NetHTTP
      NetIP
      NetNetmask
      NetSMTPS
      NetSMTPSSL
      NetSMTPTLS
      NetSSLeay
      OLEStorage_Lite
      OpenOfficeOODoc
      PackageStash
      PackageStashXS
      ParallelForkManager
      ParamsClassify
      ParamsUtil
      ParamsValidate
      ParamsValidationCompiler
      ParseRecDescent
      perl
      PerlMagick
      PodLaTeX
      POSIXstrftimeCompiler
      Readonly
      ReadonlyXS
      RoleTiny
      RTFWriter
      Socket6
      Specio
      SpreadsheetParseExcel
      SpreadsheetWriteExcel
      StringCRC32
      SubInstall
      SubName
      Switch
      TemplateToolkit
      TermReadKey
      TermUI
      TestTester
      TextCharWidth
      TextIconv
      TextSoundex
      TextTruncate
      TextWrapI18N
      TimeDate
      TimeLocal
      TryTiny
      TypesSerialiser
      UnicodeString
      URI
      URIEscape
      WWWRobotRules
      XMLLibXML
      XMLNamespaceSupport
      XMLSAX
      XMLSAXBase
      XMLSAXExpat
      XMLSimple
      YAML;
  };

  perl-drv = lib.attrValues (perls // perlsNonWeb);

  # Install all Perl packages in a single package
  perl-union = stdenv.mkDerivation {
    name = "perl-union";
    buildInputs = perl-drv;
    phases = [ "buildPhase" "installPhase" ];
    buildPhase = ''
      env
    '';
    installPhase = ''
       for package in ${lib.concatStringsSep " " (lib.filter (x: x != null) perl-drv)}; do
         ${pkgs.rsync}/bin/rsync --exclude='.packlist' --exclude='bin' --exclude='propagated-build-inputs' -qav $package/ $out/
       done
    '';
  };

  mjPerlPackages = rec {
    perls = perl-union;
    PERL5LIB = ".:${perl-union}/lib/perl5/site_perl:${perl}/lib/perl5";
    mjPerlModules =
      stdenv.mkDerivation {
        name = "majordomo-perl-modules";
        builder = with pkgs; writeScript "builder.sh" ''
              source $stdenv/setup
              mkdir -p $out/etc
              echo 'SetEnv PERL5LIB ${PERL5LIB}' > $out/perl_modules_modperl.conf
              echo 'SetEnv PERL5LIB ${PERL5LIB}' > $out/perl_modules.conf
              echo 'PERL5LIB="${PERL5LIB}"' > $out/etc/environment
            '';
      };
  };
}
