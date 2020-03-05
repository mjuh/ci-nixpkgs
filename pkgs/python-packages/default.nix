{ lib, python, fetchgit, fetchFromGitHub, fetchpatch, libffi }:

let
  inherit (python.pkgs) fetchPypi buildPythonPackage;
  inherit (lib) concatMapStrings versionAtLeast;
in

self: super: rec {
  importlib-metadata = if versionAtLeast python.version "3.8" then null else super.importlib-metadata;

  certifi = super.certifi.overrideAttrs (old: rec {
    version = "2019.11.28";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "07qg6864bk4qxa8akr967amlmsq9v310hp039mcpjx6dliylrdi5";
    };
  });

  pluggy= super.pluggy.overrideAttrs (old: rec {
    version = "0.13.1";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "1c35qyhvy27q9ih9n899f3h4sdnpgq027dbiilly2qb5cvgarchm";
    };
  });

  setuptools = super.setuptools.overrideAttrs (old: rec {
    version = "45.1.0";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      extension = "zip";
      sha256 = "1mc97cxlsv00szf4knnbsww411c5f7i9dqjgkr55wviac21jvxwi";
    };
  });

  py = super.py.overrideAttrs (old: rec {
    version = "1.8.1";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "1ajjazg3913n0sp3vjyva9c2qh5anx8ziryng935f89604a0h9sy";
    };
  });

  pytest46 = super.pytest.overrideAttrs (old: rec {
    version = "4.6.9";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "0fgkmpc31nzy97fxfrkqbzycigdwxwwmninx3qhkzp81migggs0r";
    };
    preCheck = old.preCheck + "rm testing/test_pdb.py";
  });
 
  pytest = super.pytest.overrideAttrs (old: rec {
    version = "5.3.4";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "005n7718iv0sm4w7yr347lqihc5svj2jsbpqasg706jdwn5jw4hx";
    };
    preCheck = old.preCheck + "rm testing/test_{meta,pdb}.py";
  });
 
  attrs = super.attrs.overrideAttrs (old: rec {
    version = "19.3.0";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "0wky4h28n7xnr6xv69p9z6kv8bzn50d10c3drmd9ds8gawbcxdzp";
    };
  });
 
  cython = super.cython.overrideAttrs (old: rec {
    version = "0.29.14";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "050lh336791yl76krn44zm2dz00mlhpb26bk9fq9wcfh0f3vpmp4";
    };
  });

  cryptography_vectors = super.cryptography_vectors.overrideAttrs (old: rec {
    version = "2.8";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "05pi3shqz0fgvy0d5yazza67bbnam8fkrx2ayrrclgkaqms23lvc";
    };
  });

  cryptography = (super.cryptography.overrideAttrs (old: rec {
    version = "2.8";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "0l8nhw14npknncxdnp7n4hpmjyscly6g7fbivyxkjwvlv071zniw";
    };
    patches = [];
  })).override { inherit cryptography_vectors; };

  pynacl = super.pynacl.overrideAttrs (_: { patches = [ ./pynacl-fix-tests.patch ]; });

  pyopenssl = super.pyopenssl.overrideAttrs (old: rec {
    version = "19.1.0";
    src = fetchPypi {
      pname = "pyOpenSSL";
      inherit version;
      sha256 = "01wmsq6w0frzbr3zps4ga9kmqjidp2h317jwpq1g9ah24r5lj94s";
    };
    patches = [
      (fetchpatch {
        url = https://github.com/pyca/pyopenssl/commit/0d2fd1a24b30077ead6960bd63b4a9893a57c101.patch;
        sha256 = "1c27g53qrwxddyx04sxf8yvj7xgbaabla7mc1cgbfd426rncbqf3";
      })
      (fetchpatch {
        url = https://github.com/pyca/pyopenssl/commit/d08a742573c3205348a4eec9a65abaf6c16110c4.patch;
        sha256 = "18xn8s1wpycz575ivrbsbs0qd2q48z8pdzsjzh8i60xba3f8yj2f";
      })
      (fetchpatch {
        url = https://github.com/pyca/pyopenssl/commit/60b9e10e6da7ccafaf722def630285f54510ed12.patch;
        sha256 = "0aw8qvy8m0bhgp39lmbcrpprpg4bhpssm327hyrk476wwgajk01j";
      })
      (fetchpatch {
        url = https://github.com/pyca/pyopenssl/commit/7a37cc23fcbe43abe785cd4badd14bdc7acfb175.patch;
        sha256 = "1c7zb568rs71rsl16p6dq7aixwlkgzfnba4vzmfvbmy3zsnaslq2";
      })
    ];
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

  tables= super.tables.overrideAttrs (old: rec {
    version = "3.6.1";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "0j8vnxh2m5n0cyk9z3ndcj5n1zj5rdxgc1gb78bqlyn2lyw75aa9";
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
    preBuild = "export HOME=$PWD";
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

 docutils = (super.docutils.overrideAttrs (old: rec {
    version = "0.16";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "1z3qliszqca9m719q3qhdkh0ghh90g500avzdgi7pl77x5h3mpn2";
    };
  })).override { isPy3k = false; };

  pytz = super.pytz.overrideAttrs (old: rec {
    version = "2019.3";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "1ghrk1wg45d3nymj7bf4zj03n3bh64xmczhk4pfi577hdkdhcb5h";
    };
  });

  html5lib = super.html5lib.override { pytest = pytest46; };

  botocore = super.botocore.override { docutils = docutils14; };

  boto = super.boto.overrideAttrs (_: { patches = [ ./boto.patch ]; });

  s3transfer = super.s3transfer.override { docutils = docutils14; };

  moto = super.moto.overrideAttrs (old: rec {
    version = "1.3.14";
    src = fetchPypi {
      pname = old.pname;
      inherit version;
      sha256 = "0fm09074qic24h8rw9a0paklygyb7xd0ch4890y4v8lj2pnsxbkr";
    };
    patches = [];
    postPatch = old.postPatch + ''
      rm tests/test_awslambda/test_lambda.py
      rm tests/test_core/test_request_mocking.py
      rm tests/test_datasync/test_datasync.py
      rm tests/test_sqs/test_sqs.py
      rm tests/test_dynamodb2/test_dynamodb.py
      rm tests/test_s3/test_s3_utils.py
      rm tests/test_s3/test_s3.py
      rm tests/test_kms/test_utils.py
      rm tests/test_kms/test_kms.py
    '';
  });

  docutils14 = buildPythonPackage rec {
    pname = "docutils";
    version = "0.14";
    src = fetchPypi {
      inherit pname version;
      sha256 = "0x22fs3pdmr42kvz6c654756wja305qv6cx1zbhwlagvxgr4xrji";
    };
    checkPhase = ''
      rm test3/test_writers/test_odt.py
      ${self.python}/bin/python test3/alltests.py
    '';
    postFixup = ''
      for f in $out/bin/*.py; do
        ln -s $(basename $f) $out/bin/$(basename $f .py)
      done
    '';
  };

  hypothesis = buildPythonPackage rec {
    version = "5.3.0";
    pname = "hypothesis";
    src = fetchFromGitHub {
      owner = "HypothesisWorks";
      repo = "hypothesis-python";
      rev = "hypothesis-python-${version}";
      sha256 = "0mfp8dqvdy1ism9rnf9bnylb043ywjxj7rp0h9ld2d47a7pbmrqc";
    };
    postUnpack = "sourceRoot=$sourceRoot/hypothesis-python";
    propagatedBuildInputs = [ attrs ] ++ (with super; [ coverage sortedcontainers pexpect ]);
    checkInputs = [ pytest ] ++ (with super; [ pytest_xdist flaky mock ]);
    checkPhase = ''
      rm tox.ini
      py.test tests/cover
    '';
  };

  cffi = buildPythonPackage rec {
    pname = "cffi";
    version = "1.13.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "0iikq5rn9a405n94c7s2j6kq3jv5qs9q4xyik8657b2py27ix6jr";
    };
    outputs = [ "out" "dev" ];
    propagatedBuildInputs = [ libffi super.pycparser ];
    checkInputs = [ pytest ];
    checkPhase = ''
      py.test -k "not test_char_pointer_conversion and not test_dlopen_unicode_literals"
    '';
  };

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

  junit-xml = buildPythonPackage rec {
    name = "${pname}-${version}";
    pname = "junit_xml";
    version="1.9";
    src = fetchgit {
      url = "https://github.com/kyrus/python-junit-xml.git";
      sha256 = "0b8kbjhk3j10rk0vcniy695m3h43yip6y93h1bd6jjh0cp7s09c7";
    };
    buildInputs = with super; [ pytest ];
    propagatedBuildInputs = with super; [ six ];
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
