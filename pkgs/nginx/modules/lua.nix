{ stdenv, fetchgit, nginx, luajit }:

let
  nginx-src-patched-socket-cloexec = stdenv.mkDerivation rec {
    name = "nginx-with-lua-module";
    src = nginx.src;
    phases = [ "unpackPhase" "patchPhase" "installPhase" ];
    patches = [ ./nginx-socket-cloexec.patch ];
    installPhase = "cp -av . $out";
  };
in nginx.overrideAttrs(old: rec {
  name = "nginx-lua-module";
  version = "0.10.15";
  src = fetchgit {
    url = "https://github.com/openresty/lua-nginx-module";
    rev = "v" + version;
    sha256 = "1j216isp0546hycklbr5wi8mlga5hq170hk7f2sm16sfavlkh5gz";
  };
  patches = [];
  configureFlags = old.configureFlags ++ [ "--add-dynamic-module=." ];
  makeFlags = [ "modules" ];
  buildInputs = old.buildInputs ++ [ nginx-src-patched-socket-cloexec luajit ];
  postUnpack = ''
    (
      cd lua-nginx-module || exit 1
      cp --recursive --verbose ${nginx-src-patched-socket-cloexec}/. .
    )
  '';
  # TODO: Don't hard-code version in "/include/luajit-2.1".
  preConfigure = old.preConfigure + ''
    LUAJIT_LIB=${luajit}/lib
    LUAJIT_INC=${luajit}/include/luajit-2.1
  '';
  installPhase = ''
    mkdir -p $out/etc/nginx/modules
    cp -v objs/ngx_http_lua_module.so $out/etc/nginx/modules
  '';
  meta = if old.meta != null then old.meta else old.meta // {
    description = "NGINX module for Lua programming language support";
  };
})
