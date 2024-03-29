{ buildPhp52Package, buildPhp52PearPackage, lib, pkgconfig
, imagemagick68, libmemcached, memcached, pcre, zlib, icu58 }:

{
  timezonedb = buildPhp52Package {
    name = "timezonedb";
    version = "2020.4";
    sha256 = "1ixd1cx5cnwknfyfnsqm0sgi51798sxr7k84rzyd3l9g6bdxljh7";
  };

  dbase = buildPhp52Package {
    name = "dbase";
    version = "5.1.0";
    sha256 = "15vs527kkdfp119gbhgahzdcww9ds093bi9ya1ps1r7gn87s9mi0";
  };

  intl = buildPhp52Package rec {
    name = "intl";
    version = "3.0.0";
    sha256 = "11sz4mx56pc1k7llgbbpz2i6ls73zcxxdwa1d0jl20ybixqxmgc8";
    inputs = [ icu58 ];
    patches = [
      ./patch/intl-fix-tests.patch
      ./patch/intl-fix-dateformat_format52-php52.patch
    ];
  };

  memcached = buildPhp52Package {
    name = "memcached";
    version = "2.1.0";
    sha256 = "1by4zhkq4mbk9ja6s0vlavv5ng8aw5apn3a1in84fkz7bc0l0jdw";
    inputs = [ pkgconfig zlib.dev libmemcached ];
    configureFlags = [
      "--with-zlib-dir=${zlib.dev}"
      "--with-libmemcached-dir=${libmemcached}"
    ];
    checkInputs = [ memcached ];
    preCheck = ''
     # rm tests/sasl_basic.phpt
      ${memcached}/bin/memcached -d
    '';
  };

  zendopcache = buildPhp52Package {
    name = "zendopcache";
    version = "7.0.5";
    sha256 = "1h79x7n5pylbc08cxl44fvbi1a1592n0w0mm847jirkqrhxs5r68";
  };

  imagick = buildPhp52Package {
    name = "imagick";
    version = "3.1.2";
    sha256 = "528769ac304a0bbe9a248811325042188c9d16e06de16f111fee317c85a36c93";
    inputs = [ pkgconfig imagemagick68 pcre ];
    configureFlags = [ "--with-imagick=${imagemagick68}" ];
  };

  image-text = buildPhp52PearPackage {
    name = "Image_Text";
    version = "0.7.0";
    sha256 = "1pzl0a7780hrjq1h595gj8ikg1r31c5cva72dmymgyxbw29lmbjv";
    package = "Image_Text-0.7.0/Image";
  };

  pager = buildPhp52PearPackage {
    name = "Pager";
    version = "2.5.1";
    sha256 = "0qb4nkfci2wnw66snp97ysmla2psyvlmwvvy2a96bxxsk5d3lm7l";
    package = "Pager-2.5.1/Pager";
  };

  text-captcha = buildPhp52PearPackage {
    name = "Text_CAPTCHA";
    version = "1.0.2";
    sha256 = "0zh7dq4skwv9yjwxn1mrbpbfrqy1l1n40rsz5g9lr9gs3ngq034f";
    package = "Text_CAPTCHA-1.0.2/Text";
  };
}
