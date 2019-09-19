{ stdenv, dash }:

dash.overrideAttrs (_: rec {
  postInstall = ''ln -s dash "$out/bin/sh"'';
})
