{ stdenv, makeWrapper, perlPackages }:

stdenv.mkDerivation {
  name = "cgrouptuner";
  src = ./src;

  # XXX:
  # buildPhase = ''
  #   patchShebangs $out/bin/*
  # '';

  nativeBuildInputs = [
    makeWrapper
  ];

  # XXX: Maybe in postInstall
  installPhase = ''
    mkdir -p $out/bin
    install -m755 cgrouptuner.pl $out/bin/cgrouptuner
    wrapProgram $out/bin/cgrouptuner --set PERL5LIB ${with perlPackages; makeFullPerlPath [ ListAllUtils ]}
  '';

  dontStrip = true;
}
