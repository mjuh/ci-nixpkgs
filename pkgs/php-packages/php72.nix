{ buildPhp72Package, lib, pkgconfig, fontconfig
, imagemagick, libmemcached, memcached, pcre, pcre2, rrdtool, zlib }:

{
  redis = buildPhp72Package {
    name = "redis";
    version = "4.2.0";
    sha256 = "7655d88addda89814ad2131e093662e1d88a8c010a34d83ece5b9ff45d16b380";
  };

  timezonedb = buildPhp72Package {
    name = "timezonedb";
    version = "2019.3";
    sha256 = "0s3x1xmw9w04mr67yxh6czy67d923ahn18a47p7h5r9ngk9730nv";
  };

  rrd = buildPhp72Package {
    name = "rrd";
    version = "2.0.1";
    sha256 = "39f5ae515de003d8dad6bfd77db60f5bd5b4a9f6caa41479b1b24b0d6592715d";
    inputs = [ pkgconfig rrdtool ];
  };

  memcached = buildPhp72Package {
    name = "memcached";
    version = "3.1.3";
    sha256 = "20786213ff92cd7ebdb0d0ac10dde1e9580a2f84296618b666654fd76ea307d4";
    inputs = [ pkgconfig zlib.dev libmemcached ];
    configureFlags = [
      "--with-zlib-dir=${zlib.dev}"
      "--with-libmemcached-dir=${libmemcached}"
    ];
    checkInputs = [ memcached ];
    preCheck = "${memcached}/bin/memcached -d";
  };

  imagick = buildPhp72Package rec {
    name = "imagick";
    version = "3.4.4";
    sha256 = "0xvhaqny1v796ywx83w7jyjyd0nrxkxf34w9zi8qc8aw8qbammcd";
    inputs = [ pkgconfig imagemagick pcre.dev pcre2.dev ];
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
      ln -s ${fontconfig}/etc/fonts /etc/fonts
    '';
    CXXFLAGS = "-I ${pcre.dev} -I${pcre2.dev}";
    configureFlags = [ "--with-imagick=${imagemagick.dev}" ];
  };

}
