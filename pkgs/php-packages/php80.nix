{ buildPhp80Package, lib, pkgconfig, fontconfig, fetchgit
, imagemagick, libmemcached, memcached, pcre2, rrdtool, zlib }:

{
  php80-redis = buildPhp80Package {
    name = "redis";
    version = "5.3.4";
    sha256 = "1k5l7xxb06rlwq9jbmbbr03pc74d75vgv7h5bqjkbwan6dphafab";
  };

  php80-timezonedb = buildPhp80Package {
    name = "timezonedb";
    version = "2020.4";
    sha256 = "1ixd1cx5cnwknfyfnsqm0sgi51798sxr7k84rzyd3l9g6bdxljh7";
  };

 php80-rrd = buildPhp80Package {
   name = "rrd";
   version = "2.0.3";
   sha256 = "sha256-pCFh5YzcioU7cs/ymJidy96CsPdkVt1ZzgKFTJK3MPc=";
   inputs = [ pkgconfig rrdtool ];
 };

# currently some tests was fail
 php80-memcached = buildPhp80Package {
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

#  currently is no version for php80
 php80-imagick = buildPhp80Package rec {
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
