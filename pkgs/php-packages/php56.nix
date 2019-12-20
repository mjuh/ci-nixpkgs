{ buildPhp56Package, lib, pkgconfig
, imagemagick68, libmemcached, memcached, pcre, zlib }:

{
  redis = buildPhp56Package {
    name = "redis";
    version = "4.2.0";
    sha256 = "7655d88addda89814ad2131e093662e1d88a8c010a34d83ece5b9ff45d16b380";
  };

  dbase = buildPhp56Package {
    name = "dbase";
    version = "5.1.0";
    sha256 = "15vs527kkdfp119gbhgahzdcww9ds093bi9ya1ps1r7gn87s9mi0";
  };

  timezonedb = buildPhp56Package {
    name = "timezonedb";
    version = "2019.3";
    sha256 = "0s3x1xmw9w04mr67yxh6czy67d923ahn18a47p7h5r9ngk9730nv";
  };

  memcached = buildPhp56Package {
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

  imagick = buildPhp56Package {
    name = "imagick";
    version = "3.1.2";
    sha256 = "528769ac304a0bbe9a248811325042188c9d16e06de16f111fee317c85a36c93";
    inputs = [ pkgconfig imagemagick68 pcre ];
    configureFlags = [ "--with-imagick=${imagemagick68}" ];
  };
}
