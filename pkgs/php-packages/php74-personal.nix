{ stdenv, buildPhp74PersonalPackage, lib, pkgconfig, fontconfig,
  imagemagick , libmemcached, memcached, pcre2, rrdtool, zlib,
  php74PersonalFpm, pkgs }:

{
  composer = stdenv.mkDerivation rec {
    version = "1.9.0";
    pname = "composer";

    src = pkgs.fetchurl {
      url = "https://getcomposer.org/download/${version}/composer.phar";
      sha256 = "0x88bin1c749ajymz2cqjx8660a3wxvndpv4xr6w3pib16fzdpy9";
    };

    dontUnpack = true;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin
      install -D $src $out/libexec/composer/composer.phar
      makeWrapper ${php74PersonalFpm}/bin/php $out/bin/composer \
        --add-flags "$out/libexec/composer/composer.phar" \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.unzip ]}
    '';
  };

  redis = buildPhp74PersonalPackage {
    name = "redis";
    version = "5.3.2";
    sha256 = "1cfsbxf3q3im0cmalgk76jpz581zr92z03c1viy93jxb53k2vsgl";
  };

  timezonedb = buildPhp74PersonalPackage {
    name = "timezonedb";
    version = "2020.4";
    sha256 = "1ixd1cx5cnwknfyfnsqm0sgi51798sxr7k84rzyd3l9g6bdxljh7";
  };

  rrd = buildPhp74PersonalPackage {
    name = "rrd";
    version = "2.0.1";
    sha256 = "39f5ae515de003d8dad6bfd77db60f5bd5b4a9f6caa41479b1b24b0d6592715d";
    inputs = [ pkgconfig rrdtool ];
  };

  memcached = buildPhp74PersonalPackage {
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

  imagick = buildPhp74PersonalPackage rec {
    name = "imagick";
    version = "3.4.4";
    sha256 = "0xvhaqny1v796ywx83w7jyjyd0nrxkxf34w9zi8qc8aw8qbammcd";
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
      mkdir -p $(pwd)/etc/
      ln -s ${fontconfig}/etc/fonts $(pwd)/etc/fonts
    '';
    CXXFLAGS = "-I${pcre2.dev}";
    configureFlags = [ "--with-imagick=${imagemagick.dev}" ];
  };

}
