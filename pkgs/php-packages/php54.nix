{ lib, icu58, imagemagick, imagemagick68, libmemcached, libsodium, pcre, pcre2
, php, pkgconfig, pkgs, rrdtool, zlib }:

{
  redis = buildPhp54Package {
    name = "redis";
    version = "4.2.0";
    sha256 = "7655d88addda89814ad2131e093662e1d88a8c010a34d83ece5b9ff45d16b380";
  };

  timezonedb = buildPhp54Package {
    name = "timezonedb";
    version = "2019.1";
    sha256 = "0rrxfs5izdmimww1w9khzs9vcmgi1l90wni9ypqdyk773cxsn725";
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
  };

  imagick = buildPhp54Package {
    name = "imagick";
    version = "3.4.3";
    sha256 = "1f3c5b5eeaa02800ad22f506cd100e8889a66b2ec937e192eaaa30d74562567c";
    inputs = [ pkgconfig imagemagick.dev pcre ];
    configureFlags = [ "--with-imagick=${imagemagick.dev}" ];
  };

  zendopcache = buildPhp54Package {
    name = "zendopcache";
    version = "7.0.5";
    sha256 = "1h79x7n5pylbc08cxl44fvbi1a1592n0w0mm847jirkqrhxs5r68";
  };
}
