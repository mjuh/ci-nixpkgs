{ perl,
  fetchurl,
  pkgconfig,
  buildPerlPackage,
  ModuleBuild }:

{
  TextTruncate = buildPerlPackage rec {
    name = "Text-Truncate-1.06";
    src = fetchurl {
      url = "mirror://cpan/authors/id/I/IL/ILV/${name}.tar.gz";
      sha256 = "1933361ec297253d1dd518068b863dcda131aba1da5ac887040c3d85a2d2a5d2";
    };
    buildInputs = [ ModuleBuild ];
  };

}
