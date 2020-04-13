{ lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "influxdb-subscription-cleaner";
  src = fetchFromGitHub {
    owner = "jeremyd";
    repo = "influxdb-subscription-cleaner";
    rev = "bc7b71595dd99789e6d2f9884b5f82392fa07cb2";
    sha256 = "06c4jkl72dkwk2767kchj6f8423mpbdk75g8svfly70qljxbhnc9";
  };
  goPackagePath = "github.com/jeremyd/influxdb-subscription-cleaner";
}
