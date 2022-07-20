{
  luaRestyJwt = { stdenv, lua51Packages, fetchFromGitHub }: lua51Packages.buildLuaPackage rec {
    name = "lua-resty-jwt";
    version = "0.2.2";
    src = fetchFromGitHub {
      owner = "cdbattags";
      repo = "lua-resty-jwt";
      rev = "v" + version;
      sha256 = "07ajv3iqhk80gr7v2j1fcz33xm98ad245cymb968v8lxa6k9lwz1";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/share/lua/5.1
      cp -a lib/resty $out/share/lua/5.1
    '';
  };

  luaRestyString = { stdenv, lua51Packages, fetchFromGitHub }: lua51Packages.buildLuaPackage rec {
    name = "lua-resty-string";
    version = "0.11";
    src = fetchFromGitHub {
      owner = "openresty";
      repo = "lua-resty-string";
      rev = "v${version}";
      sha256 = "02525sc0j3b00nad37d5xqdb3f58jx0k5m4pr3j5mrcqw0apqkm2";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/share/lua/5.1
      cp -a lib/resty $out/share/lua/5.1
    '';
  };

  luaRestyHmac = { stdenv, lua51Packages, fetchFromGitHub }: lua51Packages.buildLuaPackage rec {
    name = "lua-resty-hmac";
    version = "1.0";
    src = fetchFromGitHub {
      owner = "jamesmarlowe";
      repo = "lua-resty-hmac";
      rev = "v${version}";
      sha256 = "14bjp9fkmy46k7j9492cyn07fyny8n2wqi5c8j8989lla9pydl8i";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/share/lua/5.1
      cp -a lib/resty $out/share/lua/5.1
    '';
  };

  luaCrypto = { stdenv, lua51Packages, fetchFromGitHub, gnused, openssl, pkgconfig }: lua51Packages.buildLuaPackage rec {
    name = "luacrypto";
    version = "0.5.1";
    src = fetchFromGitHub {
      owner = "evanlabs";
      repo = "luacrypto";
      rev = version;
      sha256 = "055w3z0lj7gz71rm45h4vlvx4l973r25q6z1mfql68sd66bc3404";
    };
    buildInputs = [ gnused openssl pkgconfig ];
    patches = [ ./luaCrypto-configure_lualibdir.patch ];
  };

  luaRestyExec = { stdenv, lua51Packages, fetchFromGitHub }: lua51Packages.buildLuaPackage rec {
    name = "lua-resty-exec";
    version = "3.0.3";
    src = fetchFromGitHub {
      owner = "jprjr";
      repo = "lua-resty-exec";
      rev = version;
      sha256 = "1c6x852fh9n9mqfikk4gvr2vjcgzicw5yppmk57nhvvf86y2fixr";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/share/lua/5.1
      cp -a lib/resty $out/share/lua/5.1
      install -m444 lib/resty/exec.lua $out/share/lua/5.1/exec.lua
    '';
  };

  netstringLua = { stdenv, lua51Packages, fetchFromGitHub }: lua51Packages.buildLuaPackage rec {
    name = "netstringlua";
    version = "1.0.6";
    src = fetchFromGitHub {
      owner = "jprjr";
      repo = "netstring.lua";
      rev = version;
      sha256 = "0rn6n5i5ri9jsiz18a6nva1df2jzckkw7v3q8j10crbqy9qqlxj4";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/share/lua/5.1
      install -m444 src/netstring.lua $out/share/lua/5.1/netstring.lua
    '';
  };

  sockexec = { stdenv, lua51Packages, fetchFromGitHub, skalibs }: stdenv.mkDerivation rec {
    name = "sockexec";
    version = "3.1.1";
    src = fetchFromGitHub {
      owner = "jprjr";
      repo = "sockexec";
      rev = version;
      sha256 = "1qhk1ysiwzccv7069km26qz2ilph3mzwjqih6czsilsl73ls77xx";
    };
    buildInputs = [ skalibs ];
    configureFlags = [
      "--with-sysdeps=${skalibs.lib}/lib/skalibs/sysdeps"
      "--with-lib=${skalibs.lib}/lib"
    ];
    installPhase = ''
      mkdir -p $out/bin
      cp -p sockexec $out/bin
      cp -p sockexec.client $out/bin
    '';
  };

  luaRestyJitUuid = { stdenv, lua51Packages, fetchFromGitHub }: lua51Packages.buildLuaPackage rec {
    name = "lua-resty-jit-uuid";
    version = "0.0.7";
    src = fetchFromGitHub {
      owner = "thibaultcha";
      repo = "lua-resty-jit-uuid";
      rev = version;
      sha256 = "1zi8jgcdak9w5bbrm23q2llynrrbf0v59dn6hfvj7yfng6c69chb";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/share/lua/5.1/resty
      install -m444 lib/resty/jit-uuid.lua $out/share/lua/5.1/resty/jit-uuid.lua
    '';
  };

  penlight = { stdenv, lua51Packages, fetchFromGitHub }: lua51Packages.buildLuaPackage rec {
    name = "penlight";
    version = "1.6.0";
    src = fetchFromGitHub {
      owner = "stevedonovan";
      repo = "Penlight";
      rev = version;
      sha256 = "08qj9sv9xbzy7s53sgw4grnij5kscmaa8w5h0mzq77sxs16yky93";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/share/lua/5.1
      cp -a lua/pl $out/share/lua/5.1
    '';
  };

  lua-resty-lrucache = { stdenv, lua51Packages, fetchFromGitHub }: lua51Packages.buildLuaPackage rec {
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
      mkdir -p $out/share/lua/5.1/resty
      cp -a lib/resty/lrucache $out/share/lua/5.1/resty
      install lib/resty/lrucache.lua $out/share/lua/5.1/resty/lrucache.lua
    '';
  };

  lua-resty-core = { stdenv, lua51Packages, fetchFromGitHub }: lua51Packages.buildLuaPackage rec {
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
      mkdir -p $out/share/lua/5.1/resty
      cp -pr lib/resty/core $out/share/lua/5.1/resty
      install -m444 lib/resty/core.lua $out/share/lua/5.1/resty/core.lua
    '';
  };

  lua-lfs = { stdenv, lua51Packages, fetchFromGitHub }: lua51Packages.buildLuaPackage rec {
    name = "lfs-${version}";
    version = "1.7.0.2";
    src = fetchFromGitHub {
      owner = "keplerproject";
      repo = "luafilesystem";
      rev = "v" + stdenv.lib.replaceStrings [ "." ] [ "_" ] version;
      sha256 = "0zmprgkm9zawdf9wnw0v3w6ibaj442wlc6alp39hmw610fl4vghi";
    };
    postInstall = ''
      ln -s $out/lib/lua/5.1/lfs $out/lib/lfs
    '';
  };

  lua-cjson = { stdenv, lua51Packages, fetchurl }: lua51Packages.buildLuaPackage rec {
    name = "cjson-${version}";
    version = "2.1.0";
    src = fetchurl {
      url =
        "http://www.kyne.com.au/~mark/software/download/lua-${name}.tar.gz";
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

  lua-resty-http = { lua51Packages, fetchgit }:
    lua51Packages.buildLuaPackage {
      name = "lua-resty-http";
      version = "0.16.1-0";
      src = fetchgit {
        url = "https://github.com/ledgetech/lua-resty-http";
        rev = "9bf951dfe162dd9710a0e1f4525738d4902e9d20";
        sha256 = "1whwn2fwm8c9jda4z1sb5636sfy4pfgjdxw0grcgmf6451xi57nw";
        fetchSubmodules = true;
        deepClone = false;
        leaveDotGit = false;
      };
      preBuild = ''
        sed -i "s|/usr/local|$out|" Makefile
      '';
      makeFlags = [ "LUA_VERSION=5.1" ];
      meta = {
        homepage = "https://github.com/ledgetech/lua-resty-http";
        description = "Lua HTTP client cosocket driver for OpenResty / ngx_lua.";
        license.fullName = "2-clause BSD";
      };
    };
}

