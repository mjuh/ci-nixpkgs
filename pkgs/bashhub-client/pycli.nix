{ buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "pyCLI";
  version = "2.0.3";
  src = fetchPypi {
    inherit pname version;
    sha256 = "08mnzcp7aid94j9qrk42bqf20anjagql25hkbp0f26h3vg2yclxw";
  };
  doCheck = false; # Syntax error in a test.
}
