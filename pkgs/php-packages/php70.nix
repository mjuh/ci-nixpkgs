{ lib, icu58, imagemagick, imagemagick68, libmemcached, libsodium, pcre, pcre2
, php, pkgconfig, pkgs, rrdtool, zlib, buildPhp70Package }:

{
  redis = buildPhp70Package {
    name = "redis";
    version = "4.2.0";
    sha256 = "7655d88addda89814ad2131e093662e1d88a8c010a34d83ece5b9ff45d16b380";
  };

  timezonedb = buildPhp70Package {
    name = "timezonedb";
    version = "2019.1";
    sha256 = "0rrxfs5izdmimww1w9khzs9vcmgi1l90wni9ypqdyk773cxsn725";
  };

  rrd = buildPhp70Package {
    name = "rrd";
    version = "2.0.1";
    sha256 = "39f5ae515de003d8dad6bfd77db60f5bd5b4a9f6caa41479b1b24b0d6592715d";
    inputs = [ pkgconfig rrdtool ];
  };

  memcached = buildPhp70Package {
    name = "memcached";
    version = "3.1.3";
    sha256 = "20786213ff92cd7ebdb0d0ac10dde1e9580a2f84296618b666654fd76ea307d4";
    inputs = [ pkgconfig zlib.dev libmemcached ];
    configureFlags = [
      "--with-zlib-dir=${zlib.dev}"
      "--with-libmemcached-dir=${libmemcached}"
    ];
  };

  imagick = buildPhp70Package {
    name = "imagick";
    version = "3.4.3";
    sha256 = "1f3c5b5eeaa02800ad22f506cd100e8889a66b2ec937e192eaaa30d74562567c";
    inputs = [ pkgconfig imagemagick.dev pcre ];
    configureFlags = [ "--with-imagick=${imagemagick.dev}" ];
  };
}
