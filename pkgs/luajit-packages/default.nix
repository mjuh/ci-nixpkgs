{ lua,
  luajitPackages,
  fetchFromGitHub,
  openssl,
  pkgconfig }:

{
  luaRestyCore = luajitPackages.buildLuaPackage rec {
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
      mkdir -p $out/lib/lua/${lua.luaversion}
      cp -pr lib/* $out/lib/lua/${lua.luaversion}
    '';
  };

  luaRestyLrucache = luajitPackages.buildLuaPackage rec {
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
      mkdir -p $out/lib/lua/${lua.luaversion}
      cp -pr lib/resty $out/lib/lua/${lua.luaversion}
    '';
  };

  luaRestyDns = luajitPackages.buildLuaPackage rec {
    name = "lua-resty-dns";
    version = "0.21";
    src = fetchFromGitHub {
      owner = "openresty";
      repo = "lua-resty-dns";
      rev = "v${version}";
      sha256 = "0ajp8k97iiq2rrha6kgffi2j6mpqypf755imd14pahym4krk9jja";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/lib/lua/${lua.luaversion}
      cp -pr lib/resty $out/lib/lua/${lua.luaversion}
    '';
  };

  luaRestyIputils = luajitPackages.buildLuaPackage rec {
    name = "lua-resty-iputils";
    version = "0.3.0";
    src = fetchFromGitHub {
      owner = "hamishforbes";
      repo = "lua-resty-iputils";
      rev = "v${version}";
      sha256 = "1vy0h4l8n73p426c813jx15nwyxydsgr7xb2bnkz4310qb4kq32r";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/lib/lua/${lua.luaversion}
      cp -pr lib/resty $out/lib/lua/${lua.luaversion}
    '';
  };

  luaRestyJwt = luajitPackages.buildLuaPackage rec {
    name = "lua-resty-jwt";
    version = "0.1.11";
    src = fetchFromGitHub {
      owner = "SkyLothar";
      repo = "lua-resty-jwt";
      rev = "v${version}";    
      sha256 = "1nw21jg7x1d8akwv2qzybaylcsd6jj9saq70kr7r4wjg7l7lvabg";
    };
    buildPhase = ":";
    installPhase = ''
      mkdir -p $out/lib/lua/${lua.luaversion}
      cp -pr lib/resty $out/lib/lua/${lua.luaversion}
    '';
  };

  luaRestyString = luajitPackages.buildLuaPackage rec {
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
      mkdir -p $out/lib/lua/${lua.luaversion}
      cp -pr lib/resty $out/lib/lua/${lua.luaversion}
    '';
  };

  luaRestyHmac = luajitPackages.buildLuaPackage rec {
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
      mkdir -p $out/lib/lua/${lua.luaversion}
      cp -pr lib/resty $out/lib/lua/${lua.luaversion}
    '';
  };

  luaCrypto = luajitPackages.buildLuaPackage rec {
    name = "luacrypto";
    version = "0.3.2";
    src = fetchFromGitHub {
      owner = "mkottman";
      repo = "luacrypto";
      rev = version;    
      sha256 = "0yxm4msvll1z66plzsj2cbr324psw3ylgxwzgyhfdlwl5a55634z";
    };
    buildInputs = [ openssl pkgconfig ];
    patches = [ ./patches/luacrypto/configure_lualibdir.patch ];
  };

  luaRestyExec = luajitPackages.buildLuaPackage rec {
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
      mkdir -p $out/lib/lua/${lua.luaversion}
      cp -pr lib/resty $out/lib/lua/${lua.luaversion}
    '';
  };

  netstringLua = luajitPackages.buildLuaPackage rec {
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
      mkdir -p $out/lib/lua/${lua.luaversion}
      cp -p src/netstring.lua $out/lib/lua/${lua.luaversion}
    '';
  };

  luaRestyJitUuid = luajitPackages.buildLuaPackage rec {
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
      mkdir -p $out/lib/lua/${lua.luaversion}
      cp -pr lib/resty $out/lib/lua/${lua.luaversion}
    '';
  };

  penlight = luajitPackages.buildLuaPackage rec {
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
      mkdir -p $out/lib/lua/${lua.luaversion}
      cp -pr lua/pl $out/lib/lua/${lua.luaversion}
    '';
  };
}
