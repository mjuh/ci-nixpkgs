{ php52, php53, php54, php55, php56, php70, php71, php72, php73, zlib,
  libmemcached, pkgconfig, imagemagick68 }:

with import <nixpkgs> {};
# self: super:
# with lib;

let
  # inherit (lib) buildPhpPackage;

  buildPhpPackage = {
    name,
    version,
    php,
    sha256 ? null,
    src ? pkgs.fetchurl {
      url = "http://pecl.php.net/get/${name}-${version}.tgz";
      inherit (args) sha256;
    },
    inputs ? [],
    ...
  }@args:
  pkgs.stdenv.mkDerivation (args // { name = "${php.name}-${name}-${version}"; } // rec {
    inherit src;
    buildInputs = [ pkgs.autoreconfHook php ] ++ inputs;
    makeFlags = [ "EXTENSION_DIR=$(out)/lib/php/extensions" ];
    autoreconfPhase = "phpize";
    checkTarget = "test";
    doCheck = true;
    postInstall = ''
      mkdir -p  $out/etc/php.d
      ls $out/lib/php/extensions/${name}.so || mv $out/lib/php/extensions/*.so $out/lib/php/extensions/${name}.so
      echo "extension = $out/lib/php/extensions/${name}.so" > $out/etc/php.d/${name}.ini
    '';
    preCheck = ''
    for test in \
        tests/015-imagickdrawsetresolution.phpt \
    tests/016-static-methods.phpt \
    tests/034_Imagick_annotateImage_basic.phpt \
    tests/150_Imagick_setregistry.phpt \
    tests/177_ImagickDraw_composite_basic.phpt \
    tests/206_ImagickDraw_setFontSize_basic.phpt \
    tests/207_ImagickDraw_setFontFamily_basic.phpt \
    tests/208_ImagickDraw_setFontStretch_basic.phpt \
    tests/209_ImagickDraw_setFontWeight_basic.phpt \
    tests/210_ImagickDraw_setFontStyle_basic.phpt \
    tests/212_ImagickDraw_setGravity_basic.phpt \
    tests/222_ImagickDraw_setTextAlignment_basic.phpt \
    tests/223_ImagickDraw_setTextAntialias_basic.phpt \
    tests/224_ImagickDraw_setTextUnderColor_basic.phpt \
    tests/225_ImagickDraw_setTextDecoration_basic.phpt \
    tests/241_Tutorial_psychedelicFont_basic.phpt \
    tests/244_Tutorial_psychedelicFontGif_basic.phpt \
    tests/254_getConfigureOptions.phpt \
    tests/264_ImagickDraw_getTextDirection_basic.phpt \
    tests/266_ImagickDraw_getFontResolution_basic.phpt \
    tests/268_ImagickDraw_getDensity_basic.phpt \
    ext/268_ImagickDraw_getDensity_basic.phpt \
    ; do
        rm $test || true;
    done
    '';
  });

  # lib = super.lib // (import ../../lib.nix { pkgs = self; });
  # buildPhpPackage = lib.buildPhpPackage;

  buildPhp52Package = args: buildPhpPackage ({ php = php52; } // args);
  buildPhp53Package = args: buildPhpPackage ({ php = php53; } // args);
  buildPhp54Package = args: buildPhpPackage ({ php = php54; } // args);
  buildPhp55Package = args: buildPhpPackage ({ php = php55; } // args);
  buildPhp56Package = args: buildPhpPackage ({ php = php56; } // args);
  buildPhp70Package = args: buildPhpPackage ({ php = php70; } // args);
  buildPhp71Package = args: buildPhpPackage ({ php = php71; } // args);
  buildPhp72Package = args: buildPhpPackage ({ php = php72; } // args);
  buildPhp73Package = args: buildPhpPackage ({ php = php73; } // args);

in
{
  php52Packages = {
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
  };
  php53Packages = {
    timezonedb = buildPhp53Package {
      name = "timezonedb";
      version = "2019.1";
      sha256 = "0rrxfs5izdmimww1w9khzs9vcmgi1l90wni9ypqdyk773cxsn725";
    };

    dbase = buildPhp53Package {
      name = "dbase";
      version = "5.1.0";
      sha256 = "15vs527kkdfp119gbhgahzdcww9ds093bi9ya1ps1r7gn87s9mi0";
    };

    intl = buildPhp53Package {
      name = "intl";
      version = "3.0.0";
      sha256 = "11sz4mx56pc1k7llgbbpz2i6ls73zcxxdwa1d0jl20ybixqxmgc8";
      inputs = [ icu58 ];
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
  };
  php54Packages = {
    redis = buildPhp54Package {
      name = "redis";
      version = "4.2.0";
      sha256 = "7655d88addda89814ad2131e093662e1d88a8c010a34d83ece5b9ff45d16b380";
    };

    timezonedb = buildPhp54Package {
      name = "timezonedb";
      version ="2019.1";
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
  };
  php55Packages = {
    timezonedb = buildPhp55Package {
      name = "timezonedb";
      version = "2019.1";
      sha256 = "0rrxfs5izdmimww1w9khzs9vcmgi1l90wni9ypqdyk773cxsn725";
    };

    dbase = buildPhp55Package {
      name = "dbase";
      version = "5.1.0";
      sha256 = "15vs527kkdfp119gbhgahzdcww9ds093bi9ya1ps1r7gn87s9mi0";
    };

    intl = buildPhp55Package {
      name = "intl";
      version = "3.0.0";
      sha256 = "11sz4mx56pc1k7llgbbpz2i6ls73zcxxdwa1d0jl20ybixqxmgc8";
      inputs = [ icu58 ];
    };

    imagick = buildPhp55Package {
      name = "imagick";
      version = "3.1.2";
      sha256 = "528769ac304a0bbe9a248811325042188c9d16e06de16f111fee317c85a36c93";
      inputs = [ pkgconfig imagemagick68 pcre ];
      configureFlags = [ "--with-imagick=${imagemagick68}" ];
    };
  };
  php56Packages = {
    timezonedb = buildPhp56Package {
      name = "timezonedb";
      version = "2019.1";
      sha256 = "0rrxfs5izdmimww1w9khzs9vcmgi1l90wni9ypqdyk773cxsn725";
    };

    dbase = buildPhp56Package {
      name = "dbase";
      version = "5.1.0";
      sha256 = "15vs527kkdfp119gbhgahzdcww9ds093bi9ya1ps1r7gn87s9mi0";
    };

    intl = buildPhp56Package {
      name = "intl";
      version = "3.0.0";
      sha256 = "11sz4mx56pc1k7llgbbpz2i6ls73zcxxdwa1d0jl20ybixqxmgc8";
      inputs = [ icu58 ];
    };

    imagick = buildPhp56Package {
      name = "imagick";
      version = "3.1.2";
      sha256 = "528769ac304a0bbe9a248811325042188c9d16e06de16f111fee317c85a36c93";
      inputs = [ pkgconfig imagemagick68 pcre ];
      configureFlags = [ "--with-imagick=${imagemagick68}" ];
    };
  };
  php70Packages = {
    redis = buildPhp70Package {
      name = "redis";
      version = "4.2.0";
      sha256 = "7655d88addda89814ad2131e093662e1d88a8c010a34d83ece5b9ff45d16b380";
    };

    timezonedb = buildPhp70Package {
      name = "timezonedb";
      version ="2019.1";
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
  };
  php71Packages = {
    redis = buildPhp71Package {
      name = "redis";
      version = "4.2.0";
      sha256 = "7655d88addda89814ad2131e093662e1d88a8c010a34d83ece5b9ff45d16b380";
    };

    timezonedb = buildPhp71Package {
      name = "timezonedb";
      version ="2019.1";
      sha256 = "0rrxfs5izdmimww1w9khzs9vcmgi1l90wni9ypqdyk773cxsn725";
    };

    rrd = buildPhp71Package {
      name = "rrd";
      version = "2.0.1";
      sha256 = "39f5ae515de003d8dad6bfd77db60f5bd5b4a9f6caa41479b1b24b0d6592715d";
      inputs = [ pkgconfig rrdtool ];
    };

    memcached = buildPhp71Package {
      name = "memcached";
      version = "3.1.3";
      sha256 = "20786213ff92cd7ebdb0d0ac10dde1e9580a2f84296618b666654fd76ea307d4";
      inputs = [ pkgconfig zlib.dev libmemcached ];
      configureFlags = [
        "--with-zlib-dir=${zlib.dev}"
        "--with-libmemcached-dir=${libmemcached}"
      ];
    };

    imagick = buildPhp71Package {
      name = "imagick";
      version = "3.4.3";
      sha256 = "1f3c5b5eeaa02800ad22f506cd100e8889a66b2ec937e192eaaa30d74562567c";
      inputs = [ pkgconfig imagemagick.dev pcre ];
      configureFlags = [ "--with-imagick=${imagemagick.dev}" ];
    };

    libsodiumPhp = buildPhp71Package {
      name = "libsodium";
      version = "2.0.21";
      sha256 = "1sqz5987mg02hd90v695606qj5klpcrvzwfbj0yvg60vakbk3sz4";
      inputs = [ libsodium.dev ];
      configureFlags = [ "--with-sodium=${libsodium.dev}" ];
    };
  };
  php72Packages = {
    redis = buildPhp72Package {
      name = "redis";
      version = "4.2.0";
      sha256 = "7655d88addda89814ad2131e093662e1d88a8c010a34d83ece5b9ff45d16b380";
    };

    timezonedb = buildPhp72Package {
      name = "timezonedb";
      version ="2019.1";
      sha256 = "0rrxfs5izdmimww1w9khzs9vcmgi1l90wni9ypqdyk773cxsn725";
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
    };

    imagick = buildPhp72Package {
      name = "imagick";
      version = "3.4.3";
      sha256 = "1f3c5b5eeaa02800ad22f506cd100e8889a66b2ec937e192eaaa30d74562567c";
      inputs = [ pkgconfig imagemagick.dev pcre ];
      configureFlags = [ "--with-imagick=${imagemagick.dev}" ];
    };

  };
  php73Packages = {
    redis = buildPhp73Package {
      name = "redis";
      version = "4.2.0";
      sha256 = "7655d88addda89814ad2131e093662e1d88a8c010a34d83ece5b9ff45d16b380";
    };

    timezonedb = buildPhp73Package {
      name = "timezonedb";
      version ="2019.1";
      sha256 = "0rrxfs5izdmimww1w9khzs9vcmgi1l90wni9ypqdyk773cxsn725";
    };

    rrd = buildPhp73Package {
      name = "rrd";
      version = "2.0.1";
      sha256 = "39f5ae515de003d8dad6bfd77db60f5bd5b4a9f6caa41479b1b24b0d6592715d";
      inputs = [ pkgconfig rrdtool ];
    };

    memcached = buildPhp73Package {
      name = "memcached";
      version = "3.1.3";
      sha256 = "20786213ff92cd7ebdb0d0ac10dde1e9580a2f84296618b666654fd76ea307d4";
      inputs = [ pkgconfig zlib.dev libmemcached ];
      configureFlags = [
        "--with-zlib-dir=${zlib.dev}"
        "--with-libmemcached-dir=${libmemcached}"
      ];
    };

    imagick = buildPhp73Package {
      name = "imagick";
      version = "3.4.3";
      sha256 = "1f3c5b5eeaa02800ad22f506cd100e8889a66b2ec937e192eaaa30d74562567c";
      inputs = [ pkgconfig imagemagick.dev pcre pcre.dev pcre2.dev ];
      CXXFLAGS = "-I${pcre.dev} -I${pcre2.dev}";
      configureFlags = [ "--with-imagick=${imagemagick.dev}" ];
    };

  };
}
