with import <nixpkgs> {};

let
  nix-wrapper = stdenv.mkDerivation {
    name = "nix-wrapper";
    src = ../scripts;
    buildPhase = "substituteInPlace nix-wrapper.sh --replace 'command nix' ${nix}/bin/nix";
    installPhase = ''
      mkdir -p $out/bin
      cp -v nix-wrapper.sh $out/bin/nix
      chmod +x $out/bin/nix
    '';
  };
in stdenv.mkDerivation {
  name = "overlay-environment";
  buildInputs = [ nix-wrapper ];
  NIX_PATH = "nixpkgs=https://github.com/nixos/nixpkgs/archive/300846f3c982ffc3e54775fa99b4ec01d56adf65.tar.gz:nixpkgs-overlays=${builtins.getEnv "PWD"}";
}
