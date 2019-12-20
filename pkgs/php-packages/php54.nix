{ buildPhp54Package, lib, pkgconfig
, imagemagick68, libmemcached, memcached, pcre, zlib, icu58 }:

{
  redis = buildPhp54Package {
    name = "redis";
    version = "4.2.0";
    sha256 = "7655d88addda89814ad2131e093662e1d88a8c010a34d83ece5b9ff45d16b380";
  };

  dbase = buildPhp54Package {
    name = "dbase";
    version = "5.1.0";
    sha256 = "15vs527kkdfp119gbhgahzdcww9ds093bi9ya1ps1r7gn87s9mi0";
  };

  intl = buildPhp54Package rec {
    name = "intl";
    version = "3.0.0";
    sha256 = "11sz4mx56pc1k7llgbbpz2i6ls73zcxxdwa1d0jl20ybixqxmgc8";
    inputs = [ icu58 ];
    patches = [
      ./patch/intl-fix-tests.patch
      ./patch/intl-fix-dateformat_format_50+test-php54.patch
    ];
  };

  timezonedb = buildPhp54Package {
    name = "timezonedb";
    version = "2019.3";
    sha256 = "0s3x1xmw9w04mr67yxh6czy67d923ahn18a47p7h5r9ngk9730nv";
  };

  memcached = buildPhp54Package {
    name = "memcached";
    version = "2.2.0";
    sha256 = "0n4z2mp4rvrbmxq079zdsrhjxjkmhz6mzi7mlcipz02cdl7n1f8p";
    inputs = [ pkgconfig zlib.dev libmemcached ];
    configureFlags = [
      "--with-zlib-dir=${zlib.dev}"
      "--with-libmemcached-dir=${libmemcached}"
    ];
    checkInputs = [ memcached ];
    preCheck = ''
      rm tests/sasl_basic.phpt
      ${memcached}/bin/memcached -d
    '';
  };

  zendopcache = buildPhp54Package {
    name = "zendopcache";
    version = "7.0.5";
    sha256 = "1h79x7n5pylbc08cxl44fvbi1a1592n0w0mm847jirkqrhxs5r68";
  };

  imagick = buildPhp54Package {
    name = "imagick";
    version = "3.1.2";
    sha256 = "528769ac304a0bbe9a248811325042188c9d16e06de16f111fee317c85a36c93";
    inputs = [ pkgconfig imagemagick68 pcre ];
    configureFlags = [ "--with-imagick=${imagemagick68}" ];
  };
}
