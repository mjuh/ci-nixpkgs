{ python37, fetchFromGitHub }:

let
  localPython = python37.override {
    packageOverrides = self: super: {
      requests =
        super.requests.overridePythonAttrs (oldAttrs: rec {
          inherit (oldAttrs) pname;
          version = "2.23.0";
          src = super.pythonPackages.fetchPypi {
            inherit pname version;
            sha256 = "1rhpg0jb08v0gd7f19jjiwlcdnxpmqi1fhvw7r4s9avddi4kvx5k";
          };
          # Fix replacing 'Authorization: Bearer 123' with 'Authorization: Basic abc'.
          postUnpack = ''
            substituteInPlace ${pname + "-" + version}/requests/auth.py --replace "        r.headers['Authorization'] = _basic_auth_str(self.username, self.password)" ""
          '';
        });
      dateutil =
        super.dateutil.overridePythonAttrs (oldAttrs: rec {
          inherit (oldAttrs) pname;
          version = "2.8.1";
          src = super.pythonPackages.fetchPypi {
            inherit pname version;
            sha256 = "0g42w7k5007iv9dam6gnja2ry8ydwirh99mgdll35s12pyfzxsvk";
          };
        });
      future =
        super.future.overridePythonAttrs (oldAttrs: rec {
          inherit (oldAttrs) pname;
          version = "0.16.0";
          src = super.pythonPackages.fetchPypi {
            inherit pname version;
            sha256 = "1nzy1k4m9966sikp0qka7lirh8sqrsyainyf8rk97db7nwdfv773";
          };
        });
      pymongo =
        super.pymongo.overridePythonAttrs (oldAttrs: rec {
          inherit (oldAttrs) pname;
          version = "2.9";
          src = super.pythonPackages.fetchPypi {
            inherit pname version;
            sha256 = "1i4hcbcq4f8i8abxb3r89gsd1d2sww4sgp5b1nb4324jwp7r9sch";
          };
        });
      jsonpickle =
        super.jsonpickle.overridePythonAttrs (oldAttrs: rec {
          inherit (oldAttrs) pname;
          version = "0.7.0";
          src = super.pythonPackages.fetchPypi {
            inherit pname version;
            sha256 = "07i3bzq7bx211lqgfian9j3np2znh1z7l5c4s73vzvf6261hwyqp";
          };
          checkPhase = "";
        });
      humanize =
        super.humanize.overridePythonAttrs (oldAttrs: rec {
          inherit (oldAttrs) pname;
          version = "0.5.1";
          src = super.pythonPackages.fetchPypi {
            inherit pname version;
            sha256 = "06dvhm3k8lf2rayn1gxbd46y0fy1db26m3h9vrq7rb1ib08mfgx4";
          };
        });
      inflection =
        super.inflection.overridePythonAttrs (oldAttrs: rec {
          inherit (oldAttrs) pname;
          version = "0.3.1";
          src = super.pythonPackages.fetchPypi {
            inherit pname version;
            sha256 = "1jhnxgnw8y3mbzjssixh6qkc7a3afc4fygajhqrqalnilyvpzshq";
          };
        });
      click =
        super.click.overridePythonAttrs (oldAttrs: rec {
          inherit (oldAttrs) pname;
          version = "3.3";
          src = super.pythonPackages.fetchPypi {
            inherit pname version;
            sha256 = "1rfn8ml80rw3hkgpm1an5p3vdyhh7hzx4zynr8dhfl7bsw28r77p";
          };
          postPatch = "";
          doCheck = false;
        });
    };
  };
in with localPython.pkgs; buildPythonApplication rec {
  version = "2.0.2";
  pname = "bashhub-client";
  src = fetchFromGitHub {
    owner = "rcaloras";
    repo = pname;
    rev = "${version}";
    sha256 = "02qiz028vmd82cqf497fqlhw3lkldbygdsi9d56w7a0pf3dc45vm";
  };
  propagatedBuildInputs = [
    humanize
    click
    requests
    jsonpickle
    dateutil
    (callPackage ./npyscreen.nix {})
    future
    pymongo
    inflection
    (callPackage ./pycli.nix {})
    setuptools
  ];
  buildInputs = [ pytest ];
  # XXX: Don't hard-code Python version in BH_DEPS_DIRECTORY.
  prePatch = ''
    substituteInPlace bashhub/shell/bashhub.sh \
      --replace '$HOME/.bashhub/bin' $out/bin \
      --replace 'BH_DEPS_DIRECTORY=''${BH_DEPS_DIRECTORY:=$BH_HOME_DIRECTORY/deps}' BH_DEPS_DIRECTORY=$out/lib/python3.7/site-packages/bashhub/shell/deps
  '';
  patches = [
    ./bashhub-client-remove-keybind.patch
  ];
}
