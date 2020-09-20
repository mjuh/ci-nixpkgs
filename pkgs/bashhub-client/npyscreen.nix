{ buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "npyscreen";
  version = "4.10.5";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0vhjwn0dan3zmffvh80dxb4x67jysvvf1imp6pk4dsfslpwy0bk2";
  };
  doCheck = false; # Syntax error in a test.
}
