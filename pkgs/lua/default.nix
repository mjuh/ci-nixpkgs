{
  lua-resty-lrucache = { fetchFromGitHub, lua51Packages }: lua51Packages.buildLuaPackage rec {
    name = "lua-resty-lrucache";
    version = "v0.09";
    src = fetchFromGitHub {
      owner = "openresty";
      repo = "lua-resty-lrucache";
      rev = version;
      sha256 = "1mwiy55qs8bija1kpgizmqgk15ijizzv4sa1giaz9qlqs2kqd7q2";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/lib/lua/5.1
      cp -pr lib/resty $out/lib/lua/5.1
      ln -s $out/lib/lua/5.1/resty $out/lib/resty
    '';
  };

  lua-resty-core = { fetchFromGitHub, lua51Packages }: lua51Packages.buildLuaPackage rec {
    name = "lua-resty-core";
    version = "v0.1.17";
    src = fetchFromGitHub {
      owner = "openresty";
      repo = "lua-resty-core";
      rev = version;
      sha256 = "11fyli6yrg7b91nv9v2sbrc6y7z3h9lgf4lrrhcjk2bb906576a0";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/lib/lua/5.1
      cp -pr lib/resty $out/lib/lua/5.1
      ln -s $out/lib/lua/5.1/resty $out/lib/resty
    '';
  };

  lua-lfs = { stdenv, fetchFromGitHub, lua51Packages }: lua51Packages.buildLuaPackage rec {
    name = "lfs-${version}";
    version = "1.7.0.2";
    src = fetchFromGitHub {
      owner = "keplerproject";
      repo = "luafilesystem";
      rev = "v" + stdenv.lib.replaceStrings [ "." ] [ "_" ] version;
      sha256 = "0zmprgkm9zawdf9wnw0v3w6ibaj442wlc6alp39hmw610fl4vghi";
    };
  };

  lua-cjson = { lua51Packages, fetchurl }: lua51Packages.buildLuaPackage rec {
    name = "cjson-${version}";
    version = "2.1.0";
    src = fetchurl {
      url = "http://www.kyne.com.au/~mark/software/download/lua-${name}.tar.gz";
      sha256 = "0y67yqlsivbhshg8ma535llz90r4zag9xqza5jx0q7lkap6nkg2i";
    };
    preBuild = ''
      sed -i "s|/usr/local|$out|" Makefile
    '';
    makeFlags = [ "LUA_VERSION=5.1" ];
    postInstall = ''
      rm -rf $out/share/lua/5.1/cjson/tests
    '';
    installTargets = "install install-extra";
  };
}
