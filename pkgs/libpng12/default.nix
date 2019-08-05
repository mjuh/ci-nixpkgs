{ stdenv, fetchurl, zlib }:

stdenv.mkDerivation rec {
  name = "libpng-1.2.59";
  src = fetchurl {
    url = "mirror://sourceforge/libpng/${name}.tar.xz";
    sha256 = "b4635f15b8adccc8ad0934eea485ef59cc4cae24d0f0300a9a941e51974ffcc7";
  };
  buildInputs = [ zlib ];
  doCheck = true;
  checkTarget = "test";
}
