{ stdenv, coreutils }:

with import <nixpkgs> {};
with lib;

let
  generic =
    { version
    , sha256
    , url
    }:
    stdenv.mkDerivation {
      inherit version;
      name = "zendguard-${version}";
      src = fetchurl {
        url = url;
        inherit sha256;
      };
      installPhase = ''
                  mkdir -p $out/
                  echo "libs is:"
                  bash -c "mv */Zend*.so $out || mv *.so $out"
      '';
      outputs = [ "out" ];
      enableParallelBuilding = true;
};

in {
  loader-php53 = generic {
    version = "5.3";
    sha256 = "1600ldv0pm41jxzci8n5ma99v802lxd2ra4i8mldvv36vmzqg0k9";
    url = "https://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz";
  };
  loader-php54 = generic {
    version = "5.4";
    sha256 = "1pqrlarxxpmj3l2gjh4lrl370725px0ag210jgh9zqycq64hp8lw";
    url = "https://downloads.zend.com/guard/6.0.0/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz";
  };
  loader-php55 = generic {
    version = "5.5";
    sha256 = "11dmvpfa09zbq83mnba5xbiaa2m953b5x5hqjm5xh3dc33afz8ni";
    url = "https://downloads.zend.com/guard/7.0.0/zend-loader-php5.5-linux-x86_64_update1.tar.gz";
  };
  loader-php56 = generic {
    version = "5.6";
    sha256 = "0kz1dnz0hazqj0n4gcn03fafq10g2jygmxr7mnn023d9648yd633";
    url = "https://downloads.zend.com/guard/7.0.0/zend-loader-php5.6-linux-x86_64_update1.tar.gz";
  };
}
