{ stdenv, callPackage, fetchFromGitHub, final }:

let
  overrides = callPackage ../luajit-packages {};
  luaPackages = callPackage <nixpkgs/pkgs/development/lua-modules> { lua = final; overrides = overrides; };
in

stdenv.mkDerivation rec {
  name = "luajit";
  version = "2.1-20190507";
  luaversion = "5.1";
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
  LuaPathSearchPaths = [ "lib/lua/${luaversion}/?.lua" "share/lua/${luaversion}/?.lua"
                         "share/lua/${luaversion}/?/init.lua" "lib/lua/${luaversion}/?/init.lua"
                         "share/${name}/?.lua" ];
  LuaCPathSearchPaths = [ "lib/lua/${luaversion}/?.so" "share/lua/${luaversion}/?.so" ];
  setupHook = luaPackages.lua-setup-hook LuaPathSearchPaths LuaCPathSearchPaths;
  passthru = rec {
    buildEnv = callPackage <nixpkgs/pkgs/development/interpreters/lua-5/wrapper.nix> {
      lua = final;
      inherit (luaPackages) requiredLuaModules;
    };
    withPackages = import <nixpkgs/pkgs/development/interpreters/lua-5/with-packages.nix> {
      inherit buildEnv luaPackages;
    };
    pkgs = luaPackages;
    interpreter = "${final}/bin/lua";
  };
  meta = { platforms = stdenv.lib.platforms.linux; };
}
