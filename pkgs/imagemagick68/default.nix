{ stdenv, fetchurl, pkgconfig, bzip2, fontconfig, freetype, libjpeg,
  libpng, libtiff, libxml2, zlib, librsvg, libtool, jasper }:

stdenv.mkDerivation rec {
  version = "6.8.8-7";
  name = "ImageMagick-${version}";

  src = fetchurl {
    url = "https://mirror.sobukus.de/files/src/imagemagick/${name}.tar.xz";
    sha256 = "1x5jkbrlc10rx7vm344j7xrs74c80xk3n1akqx8w5c194fj56mza";
  };

  enableParallelBuilding = true;

  configureFlags = ''
    --with-gslib
    --with-frozenpaths
    ${if librsvg != null then "--with-rsvg" else ""}
  '';

  buildInputs =
    [ pkgconfig bzip2 fontconfig freetype libjpeg libpng libtiff libxml2 zlib librsvg
      libtool jasper
    ];

  postInstall = ''(cd "$out/include" && ln -s ImageMagick* ImageMagick)'';
}
