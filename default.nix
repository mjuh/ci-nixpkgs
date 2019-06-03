# Majordomo nix overlay

self: super:

rec {
  inherit (super) stdenv fetchFromGitHub lua51Packages gettext;

  lib = super.lib // (import ./lib.nix { pkgs = self; });

  openrestyLuajit2 = stdenv.mkDerivation rec {
    name = "openresty-luajit2";
    version = "2.1-20190507";
    src = fetchFromGitHub {
      owner = "openresty";
      repo = "luajit2";
      rev = "v${version}";
      sha256 = "0vy9kgjh8ihx7qg3qiwnlpqgxh6mpqq25rj96bzj1449fq38xbbq";
    };
    patchPhase = ''
      substituteInPlace Makefile --replace /usr/local "$out"
      substituteInPlace src/Makefile --replace gcc cc
      substituteInPlace Makefile --replace ldconfig ${stdenv.cc.libc.bin or stdenv.cc.libc}/bin/ldconfig
    '';
    configurePhase = false;
    buildFlags = [ "amalg" ];
    enableParallelBuilding = true;
    installPhase   = ''
      make install PREFIX="$out"
      ( cd "$out/include"; ln -s luajit-*/* . )
      ln -s "$out"/bin/luajit-* "$out"/bin/lua
    '';
  };

  nginxLua = {
    name = "lua-nginx-module";
    version = "0.10.15";
    src = fetchFromGitHub {
      owner = "openresty";
      repo = "lua-nginx-module";
      rev = "28cf5ce3b6ec8e7ab44eadac9cc1c3b6f5c387ba";
      sha256 = "1j216isp0546hycklbr5wi8mlga5hq170hk7f2sm16sfavlkh5gz";
    };
    inputs = [ openrestyLuajit2 ];
    preConfigure = ''
      export LUAJIT_LIB="${openrestyLuajit2}/lib"
      export LUAJIT_INC="${openrestyLuajit2}/include/luajit-2.0"
    '';
  };

  nginxVts = {
    name = "vts-nginx-module";
    version = "0.1.18";
    src = fetchFromGitHub {
      owner = "vozlt";
      repo = "nginx-module-vts";
      rev = "d6aead19ab52834ad748f14dc536b9128ee22372";
      sha256 = "1jq2s9k7hah3b317hfn9y3g1q4g4x58k209psrfsqs718a9sw8c7";
    };
  };

  nginxSysGuard = {
    name = "sysguard-nginx-module";
    version = "0.1.0";
    src = fetchFromGitHub {
      owner = "vozlt";
      repo = "nginx-module-sysguard";
      rev = "e512897f5aba4f79ccaeeebb51138f1704a58608";
      sha256 = "19c6w6wscbq9phnx7vzbdf4ay6p2ys0g7kp2rmc9d4fb53phrhfx";
    };
  };

  luaRestyCore = lua51Packages.buildLuaPackage rec {
    name = "lua-resty-core";
    version = "0.1.17";
    src = fetchFromGitHub {
      owner = "openresty";
      repo = "lua-resty-core";
      rev = "v${version}";
      sha256 = "11fyli6yrg7b91nv9v2sbrc6y7z3h9lgf4lrrhcjk2bb906576a0";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/lib/lua/5.1
      cp -pr lib/* $out/lib/lua/5.1
    '';
  };

  luaRestyLrucache = lua51Packages.buildLuaPackage rec {
    name = "lua-resty-lrucache";
    version = "0.0.9";
    src = fetchFromGitHub {
      owner = "openresty";
      repo = "lua-resty-lrucache";
      rev = "v0.09";
      sha256 = "1mwiy55qs8bija1kpgizmqgk15ijizzv4sa1giaz9qlqs2kqd7q2";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/lib/lua/5.1
      cp -pr lib/resty $out/lib/lua/5.1
    '';
  };

  mjerrors = stdenv.mkDerivation rec {
    name = "mjerrors";
    buildInputs = [ gettext ];
    src = fetchGit {
      url = "git@gitlab.intr:shared/http_errors.git";
      ref = "master";
      rev = "f83136c7e6027cb28804172ff3582f635a8d2af7";
    };
    outputs = [ "out" ];
    postInstall = ''
      mkdir $out/html
      cp -pr /tmp/mj_http_errors/* $out/html/
    '';
  };
}
