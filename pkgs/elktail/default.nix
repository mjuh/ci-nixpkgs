{ lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "elktail";

  src = fetchFromGitHub {
    owner = "knes1";
    repo = "elktail";
    rev = "e350718f506108fef413cab3bb84fb79e3892ebd";
    sha256 = "0f16s4pihjvvdwsy8h8zrzfngsclb0d7fp1fx49jl3di2jd2lf4w";
  };

  goDeps =  ./deps.nix;
  goPackagePath = "github.com/knes1/elktail";

  excludedPackages = "test";
}
