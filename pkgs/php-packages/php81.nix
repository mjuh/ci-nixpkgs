{ buildPhp81Package, lib, pkgconfig, fontconfig, fetchgit
, imagemagick, libmemcached, memcached, pcre2, rrdtool, zlib }:

{
  php81-redis = buildPhp81Package {
    name = "redis";
    version = "5.3.4";
    sha256 = "1k5l7xxb06rlwq9jbmbbr03pc74d75vgv7h5bqjkbwan6dphafab";
  };

  php81-timezonedb = buildPhp81Package {
    name = "timezonedb";
    version = "2020.4";
    sha256 = "1ixd1cx5cnwknfyfnsqm0sgi51798sxr7k84rzyd3l9g6bdxljh7";
  };

  php81-protobuf = buildPhp81Package {
    name = "protobuf";
    version = "3.19.4";
    sha256 = "sha256-ijo+UZz+Hh3F8FUJmcUIbKBLkv4t4CWIrbRUfUp7Zbo=";
    inputs = [ pkgconfig ];
  };

  php81-grpc = buildPhp81Package {
    name = "grpc";
    version = "1.43.0";
    sha256 = "sha256-9LQaY5hmYiH6A/fgHSWRtLDjKq8a7KUoEObvDEoW0FU=";
    inputs = [ pkgconfig zlib.dev ];
  };

# currently some tests was fail
 php81-rrd = buildPhp81Package {
   name = "rrd";
   version = "2.0.1";
   sha256 = "39f5ae515de003d8dad6bfd77db60f5bd5b4a9f6caa41479b1b24b0d6592715d";
   inputs = [ pkgconfig rrdtool ];
 };

# currently some tests was fail
 php81-memcached = buildPhp81Package {
   name = "memcached";
   version = "3.1.5";
   sha256 = "1z91j20ir7nbpvk5689jyzs6va2ivr0v42459mnf34wmhdgy925j";
   inputs = [ pkgconfig zlib.dev libmemcached ];
   configureFlags = [
     "--with-zlib-dir=${zlib.dev}"
     "--with-libmemcached-dir=${libmemcached}"
   ];
   checkInputs = [ memcached ];
   preCheck = "${memcached}/bin/memcached -d";
 };

#  currently is no version for php81
 php81-imagick = buildPhp81Package rec {
   name = "imagick";
   version = "3.6.0";
   sha256 = "0zlls94dfnd1zkh8k7wycv9clcg7j3jmczcmwx09mm8dszr6aaaf";
   inputs = [ pkgconfig imagemagick pcre2.dev ];
   checkInputs = [ fontconfig ];
   FONTCONFIG_PATH = "/etc/fonts";
   FONTCONFIG_FILE = "fonts.conf";
   testsToSkip = builtins.concatStringsSep " " [
     "tests/150_Imagick_setregistry.phpt"
     "tests/254_getConfigureOptions.phpt"
     #«Uncaught ImagickException: non-conforming drawing primitive definition `text' @…»
     #consider replacing imagemagick by imagemagickBig for freetype & ghostscript support
     "tests/034_Imagick_annotateImage_basic.phpt"
     "tests/177_ImagickDraw_composite_basic.phpt"
     "tests/206_ImagickDraw_setFontSize_basic.phpt"
     "tests/207_ImagickDraw_setFontFamily_basic.phpt"
     "tests/208_ImagickDraw_setFontStretch_basic.phpt"
     "tests/209_ImagickDraw_setFontWeight_basic.phpt"
     "tests/210_ImagickDraw_setFontStyle_basic.phpt"
     "tests/212_ImagickDraw_setGravity_basic.phpt"
     "tests/222_ImagickDraw_setTextAlignment_basic.phpt"
     "tests/223_ImagickDraw_setTextAntialias_basic.phpt"
     "tests/224_ImagickDraw_setTextUnderColor_basic.phpt"
     "tests/225_ImagickDraw_setTextDecoration_basic.phpt"
     "tests/241_Tutorial_psychedelicFont_basic.phpt"
     "tests/244_Tutorial_psychedelicFontGif_basic.phpt"
     "tests/264_ImagickDraw_getTextDirection_basic.phpt"
     "tests/266_ImagickDraw_getFontResolution_basic.phpt"
     "tests/279_ImagickDraw_setTextInterlineSpacing.phpt"
   ];
   preCheck = ''
     rm ${testsToSkip}
#      mkdir -p $(pwd)/etc/
     ln -s ${fontconfig}/etc/fonts $(pwd)/etc/fonts
   '';
   CXXFLAGS = "-I${pcre2.dev}";
   configureFlags = [ "--with-imagick=${imagemagick.dev}" ];
 };
}