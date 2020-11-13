{ buildPhp53Package, lib, pkgconfig
, imagemagick68, libmemcached, memcached, pcre, zlib, icu58 }:

{
  timezonedb = buildPhp53Package {
    name = "timezonedb";
    version = "2020.4";
    sha256 = "1ixd1cx5cnwknfyfnsqm0sgi51798sxr7k84rzyd3l9g6bdxljh7";
  };

  memcached = buildPhp53Package {
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

  dbase = buildPhp53Package {
    name = "dbase";
    version = "5.1.0";
    sha256 = "15vs527kkdfp119gbhgahzdcww9ds093bi9ya1ps1r7gn87s9mi0";
  };

  intl = buildPhp53Package rec {
    name = "intl";
    version = "3.0.0";
    sha256 = "11sz4mx56pc1k7llgbbpz2i6ls73zcxxdwa1d0jl20ybixqxmgc8";
    inputs = [ icu58 ];
    patches = [ ./patch/intl-fix-tests.patch ];
  };

  zendopcache = buildPhp53Package {
    name = "zendopcache";
    version = "7.0.5";
    sha256 = "1h79x7n5pylbc08cxl44fvbi1a1592n0w0mm847jirkqrhxs5r68";
  };

  imagick = buildPhp53Package {
    name = "imagick";
    version = "3.1.2";
    sha256 = "528769ac304a0bbe9a248811325042188c9d16e06de16f111fee317c85a36c93";
    inputs = [ pkgconfig imagemagick68 pcre ];
    configureFlags = [ "--with-imagick=${imagemagick68}" ];
  };
}
