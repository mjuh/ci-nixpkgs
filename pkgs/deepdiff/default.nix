{ stdenv
, pkgs
, lib
, python37Packages
}:

python37Packages.buildPythonPackage rec {
  name = "${pname}-${version}";
  pname = "deepdiff";
  version="4.0.8";
  src = python37Packages.fetchPypi {
    inherit pname version;
    sha256 = "16lmwr4vb7fh9hvx5wakpfs7inwb86gxifa5bhxkh0cw1q123jk2";
  };
  propagatedBuildInputs = [
    python37Packages.jsonpickle
    python37Packages.ordered-set
  ];
  checkInputs = [
    python37Packages.pytest
    python37Packages.mock
  ];
}
