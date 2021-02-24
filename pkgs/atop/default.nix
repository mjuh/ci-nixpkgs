{ stdenv, atop, makeWrapper, coreutils, gnugrep, procps, findutils }:

atop.overrideAttrs (_: {
  nativeBuildInputs = [ makeWrapper ];
  postInstall = ''
    install -m 755 atop.daily "$out"/bin/atop.daily
    wrapProgram "$out"/bin/atop.daily \
        --set PATH ${coreutils}/bin:${gnugrep}/bin:${procps}/bin:${findutils}/bin
  '';
})
