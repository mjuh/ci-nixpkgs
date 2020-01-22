{ lib, python37Packages, fetchpatch }:

let
  inherit (python37Packages) fetchPypi buildPythonPackage;
  inherit (lib) concatMapStrings dropAttrs;
in

self: super: rec {
  cython = super.cython.overrideAttrs (old: rec {
    version = "0.29.14";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "050lh336791yl76krn44zm2dz00mlhpb26bk9fq9wcfh0f3vpmp4";
    };
  });

  lxml = super.lxml.overrideAttrs (old: rec {
    version = "4.4.2";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "01nvb5j8vs9nk4z5s3250b1m22b4d08kffa36if3g1mdygdrvxpg";
    };
  });

  mysqlclient = super.mysqlclient.overrideAttrs (old: rec {
    version = "1.4.6";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "05ifrfz7rrl7j4gq4xz5acd76lrnmry9vrvg98hknakm72damzgk";
    };
  });

  pillow = super.pillow.overrideAttrs (old: rec {
    version = "7.0.0";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "0il99hpk1nz8nf11w4s1fl46g00l234x687ib91k3q4m82kdk7jd";
    };
  });

  numpy = super.numpy.overrideAttrs (old: rec {
    version = "1.18.1";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      extension = "zip";
      sha256 = "0xzb50kb1f63sv11mqp36psbxvkciq4j2xvywhb4aibbx775kzxn";
    };
    nativeBuildInputs = old.nativeBuildInputs ++ [ cython ];
    propagatedBuildInputs = old.propagatedBuildInputs or [] ++ [ pybind11 ];
  });

  numexpr = super.numexpr.overrideAttrs (old: rec {
    version = "2.7.1";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "1c82z0zx0542j9df6ckjz6pn1g13b21hbza4hghcw6vyhbckklmh";
    };
    preBuild = "ln -s ${numpy.cfg} site.cfg";
  });

  scipy = (super.scipy.overrideAttrs (old: rec {
    version = "1.4.1";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "0ndw7zyxd2dj37775mc75zm4fcyiipnqxclc45mkpxy8lvrvpqfy";
    };
  })).override { inherit numpy; };

  pandas = (super.pandas.overrideAttrs (old: rec {
    version = "0.25.3";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "191048m6kdc6yfvqs9w412lq60cfvigrsb57y0x116lwibgp9njj";
    };
    disabledTests = old.disabledTests + concatMapStrings (s: " and not " + s) [
      "test_ops"
      "test_numpy_compat"
    ];
  })).override { inherit scipy; };

  pybind11 = buildPythonPackage rec {
    pname = "pybind11";
    version = "2.4.3";
    src = fetchPypi {
      inherit pname version;
      sha256 = "0n2plw8gyd974a00vwhl6dwa1dbv5sfh54i6x7sgg4dl7zsxxrkj";
    };
    doCheck = false;
    patches = [
      (fetchpatch {
        url = https://github.com/pybind/pybind11/commit/44a40dd61e5178985cfb1150cf05e6bfcec73042.patch;
        sha256 = "047nzyfsihswdva96hwchnp4gj2mlbiqvmkdnhxrfi9sji8x31ka";
      })
    ];
  };

  deepdiff = buildPythonPackage rec {
    name = "${pname}-${version}";
    pname = "deepdiff";
    version="4.0.9";
    src = fetchPypi {
      inherit pname version;
      sha256 = "0nn3c2kk5xkncdk8r1yw9y1klslrgqh9j34wlpd8wlwhiqwl68sy";
    };
    propagatedBuildInputs = with super; [
      jsonpickle
      ordered-set
    ];
    checkInputs = with super; [
      pytest
      mock
    ];
  };

  pytest-cov = buildPythonPackage rec {
    name = "${pname}-${version}";
    pname = "pytest-cov";
    version = "2.8.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "0avzlk9p4nc44k7lpx9109dybq71xqnggxb9f4hp0l64pbc44ryc";
    };
    propagatedBuildInputs = with super; [
      pytest
      coverage
    ];
  };

  pytest-black = buildPythonPackage rec {
    name = "${pname}-${version}";
    pname = "pytest-black";
    version = "0.3.7";
    src = fetchPypi {
      inherit pname version;
      sha256 = "03gwwy1h3qnfh6vpfhgsa5ag53a9sw1g42sc2s8a2hilwb7yrfvm";
    };
    propagatedBuildInputs = with super; [
      black
      setuptools_scm
      toml
      pytest
    ];
  };
}
