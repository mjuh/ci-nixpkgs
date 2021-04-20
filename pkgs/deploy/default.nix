{ stdenv
, git
, skopeo
, docker
, util-linux
, shellcheck }:

stdenv.mkDerivation {
  inherit git skopeo docker;
  utilLinux = util-linux;

  pname = "deploy";
  version = "0.0.1";

  src = ./deploy-container.sh;
  dontUnpack = true;

  buildPhase = ''
    cp "$src" deploy.sh
    substituteAllInPlace deploy.sh
  '';

  doCheck = true;
  checkInputs = [
    shellcheck
  ];
  checkPhase = ''
    shellcheck deploy.sh
  '';

  installPhase = ''
    install -m 755 deploy.sh "$out"
  '';
}
