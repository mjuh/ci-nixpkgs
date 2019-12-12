{ lib, icu58, imagemagick, imagemagick68, libmemcached, libsodium, pcre, pcre2
, php, pkgconfig, pkgs, rrdtool, zlib, buildPhp52Package, buildPhp52PearPackage }:

{
  timezonedb = buildPhp52Package {
    name = "timezonedb";
    version = "2019.1";
    sha256 = "0rrxfs5izdmimww1w9khzs9vcmgi1l90wni9ypqdyk773cxsn725";
  };

  dbase = buildPhp52Package {
    name = "dbase";
    version = "5.1.0";
    sha256 = "15vs527kkdfp119gbhgahzdcww9ds093bi9ya1ps1r7gn87s9mi0";
  };

  intl = buildPhp52Package {
    name = "intl";
    version = "3.0.0";
    sha256 = "11sz4mx56pc1k7llgbbpz2i6ls73zcxxdwa1d0jl20ybixqxmgc8";
    inputs = [ icu58 ];
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
