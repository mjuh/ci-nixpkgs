{ fetchFromGitHub, openrestyLuajit2 }:

{
   develkit = {
      src = fetchFromGitHub {
        owner = "simplresty";
        repo = "ngx_devel_kit";
        rev = "v0.3.1";
        sha256 = "1c5zfpvm0hrd9lp8rasmw79dnr2aabh0i6y11wzb783bp8m3p2sq";
      };
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

  nginxLuaIo = {
    src = fetchFromGitHub {
      owner = "tokers";
      repo = "lua-io-nginx-module";
      rev = "master";
      sha256 = "04hg1rzljfdcd5jhhbnk8790r273kvxpfq421h2jlzy3pazkhjgy";
    };
  };
}
