{ fetchurl, fetchFromGitHub, openssl_1_0_2 }:

self: super:

let

inherit (super) lua buildLuaPackage buildLuarocksPackage luafilesystem;

in 

rec {
  getLuaPathList = _: lua.LuaPathSearchPaths;
  getLuaCPathList = _: lua.LuaCPathSearchPaths;

  lua-resty-core = buildLuarocksPackage rec {
    pname = "lua-resty-core";
    version = "0.1.17";
    src = fetchFromGitHub {
      owner = "openresty";
      repo = pname;
      rev = "v${version}";
      sha256 = "11fyli6yrg7b91nv9v2sbrc6y7z3h9lgf4lrrhcjk2bb906576a0";
    };
    knownRockspec = (fetchurl {
      url = "https://luarocks.org/manifests/avlubimov/${pname}-${version}-4.rockspec";
      sha256 = "0bhym2p39gmrkdxg6p5j0lv8znhqsy47hh5irh3w98dla9aw2lcp";
    }).outPath;
    propagatedBuildInputs = [ lua-resty-lrucache ];
  };

  lua-resty-lrucache = buildLuarocksPackage rec {
    pname = "lua-resty-lrucache";
    version = "0.09";
    src = fetchFromGitHub {
      owner = "openresty";
      repo = "lua-resty-lrucache";
      rev = "v${version}";
      sha256 = "1mwiy55qs8bija1kpgizmqgk15ijizzv4sa1giaz9qlqs2kqd7q2";
    };
    knownRockspec = (fetchurl {
      url = "https://luarocks.org/manifests/avlubimov/${pname}-${version}-2.rockspec";
      sha256 = "1brx1n6ynndi52sm5yjy33rfgaxmi8kfxvn50wc89kfyync06xq8";
    }).outPath;
  };

  lua-resty-dns = buildLuarocksPackage rec {
    pname = "lua-resty-dns";
    version = "0.21";
    src = fetchFromGitHub {
      owner = "openresty";
      repo = "lua-resty-dns";
      rev = "v${version}";
      sha256 = "0ibarb7w0wi8f8nga909m2w72yzr03g5f2y7ha1kc81vz3p5qxnh";
    };
    knownRockspec = (fetchurl {
      url = "https://luarocks.org/manifests/avlubimov/${pname}-${version}-1.rockspec";
      sha256 = "0r8n4fqzlxn1l08b6bxqx53gbkmgfp97zv9xssvykyk7yf44sji1";
    }).outPath;
  };

  lua-resty-iputils = buildLuarocksPackage rec {
    pname = "lua-resty-iputils";
    version = "0.3.0";
    src = fetchFromGitHub {
      owner = "hamishforbes";
      repo = "lua-resty-iputils";
      rev = "v${version}";
      sha256 = "1vy0h4l8n73p426c813jx15nwyxydsgr7xb2bnkz4310qb4kq32r";
    };
    knownRockspec = (fetchurl {
      url = "https://luarocks.org/manifests/hamish/${pname}-${version}-1.rockspec";
      sha256 = "0bkbxwrhv1xl3knybqh7qglxh0lpcsjy3n944rwpjcf2lps3af4z";
    }).outPath;
  };

  lua-resty-jwt = buildLuarocksPackage rec {
    pname = "lua-resty-jwt";
    version = "0.2.0";
    src = fetchFromGitHub {
      owner = "cdbattags";
      repo = "lua-resty-jwt";
      rev = "v${version}";    
      sha256 = "1xazadps0p6zdb3xscz6drb6dh610qh81hks686iljdybsplgwg5";
    };
    knownRockspec = (fetchurl {
      url = "https://luarocks.org/manifests/cdbattags/${pname}-${version}-0.rockspec";
      sha256 = "1a9dxijj2gab9c1ibvb8q72b142mk10wwrnklks9iailblmywpwi";
    }).outPath;
    propagatedBuildInputs = [ lua-resty-hmac lua-resty-string ];
  };

  lua-resty-string = buildLuaPackage rec {
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
    rocksSubdir = "${name}-${version}-rocks";
  };

  lua-resty-hmac = buildLuarocksPackage rec {
    pname = "lua-resty-hmac";
    version = "1.0";
    src = fetchFromGitHub {
      owner = "jamesmarlowe";
      repo = "lua-resty-hmac";
      rev = "v${version}";    
      sha256 = "14bjp9fkmy46k7j9492cyn07fyny8n2wqi5c8j8989lla9pydl8i";
    };
    knownRockspec = (fetchurl {
      url = "https://luarocks.org/manifests/jameskmarlowe/${pname}-v${version}-1.rockspec";
      sha256 = "0j0hg3wxbdxhp86m793f26qc0cld3wz54ixc0nqbhfgp4jasgjzs";
    }).outPath;
    propagatedBuildInputs = [ luacrypto ];
  };

  luacrypto = buildLuarocksPackage rec {
    pname = "luacrypto";
    version = "0.3.2";
    src = fetchFromGitHub {
      owner = "mkottman";
      repo = "luacrypto";
      rev = version;
      sha256 = "0yxm4msvll1z66plzsj2cbr324psw3ylgxwzgyhfdlwl5a55634z";
    };
    knownRockspec = (fetchurl {
      url = "https://luarocks.org/manifests/starius/${pname}-${version}-2.rockspec";
      sha256 = "0703qgj6y4hhca3g7y0g52w7lw2d4b7cmkjmz9wqs0p92ahbnhv3";
    }).outPath;
    buildInputs = [ openssl_1_0_2.dev ];
  };

  lua-resty-exec = buildLuarocksPackage rec {
    pname = "lua-resty-exec";
    version = "3.0.3";
    src = fetchFromGitHub {
      owner = "jprjr";
      repo = "lua-resty-exec";
      rev = version;
      sha256 = "1c6x852fh9n9mqfikk4gvr2vjcgzicw5yppmk57nhvvf86y2fixr";
    };
    knownRockspec = (fetchurl {
      url = "https://luarocks.org/manifests/jprjr/${pname}-${version}-0.rockspec";
      sha256 = "06wpgmyhhxdqb7ajryhwys3927wgmfyrxv32brhvfj0ag85ib9c3";
    }).outPath;
    propagatedBuildInputs = [ netstring ];
  };

  netstring = buildLuarocksPackage rec {
    pname = "netstring";
    version = "1.0.6";
    src = fetchFromGitHub {
      owner = "jprjr";
      repo = "netstring.lua";
      rev = version;
      sha256 = "0rn6n5i5ri9jsiz18a6nva1df2jzckkw7v3q8j10crbqy9qqlxj4";
    };
    knownRockspec = (fetchurl {
      url = "https://luarocks.org/manifests/jprjr/${pname}-${version}-0.rockspec";
      sha256 = "0hv5frxwas608qxiipp0q7bs7f3bll71hbl40yhgjsqhnh1qkkdb";
    }).outPath;
  };

  lua-resty-jit-uuid = buildLuarocksPackage rec {
    pname = "lua-resty-jit-uuid";
    version = "0.0.7";
    src = fetchFromGitHub {
      owner = "thibaultcha";
      repo = "lua-resty-jit-uuid";
      rev = version;
      sha256 = "1zi8jgcdak9w5bbrm23q2llynrrbf0v59dn6hfvj7yfng6c69chb";
    };
    knownRockspec = (fetchurl {
      url = "https://luarocks.org/manifests/thibaultcha/${pname}-${version}-2.rockspec";
      sha256 = "01spyvz1vilx9j3gys2m44nqix6590596ghc042jp44p0091m0cj";
    }).outPath;
  };

  penlight = buildLuarocksPackage rec {
    pname = "penlight";
    version = "1.7.0";
    src = fetchFromGitHub {
      owner = "Tieske";
      repo = "Penlight";
      rev = version;
      sha256 = "0qc2d1riyr4b5a0gnsmdw2lz5pw65s4ac60hc34w3mmk9l6yg6nl";
    };
    knownRockspec = (fetchurl {
      url = "https://luarocks.org/manifests/tieske/${pname}-${version}-1.rockspec";
      sha256 = "007wa3gzxwszqbnzf6cg2ddm12jf54ciiibq2v9qqdsalx0xbmsw";
    }).outPath;
    propagatedBuildInputs = [ luafilesystem ];
  };

  luaexpat = super.luaexpat.overrideAttrs (oldAttrs: { meta = oldAttrs.meta // { broken = true; }; });
}
