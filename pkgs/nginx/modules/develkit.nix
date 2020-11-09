{ stdenv, fetchFromGitHub, nginx }:

nginx.overrideAttrs(old: rec {
  name = "nginx-develkit-module";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "simplresty";
    repo = "ngx_devel_kit";
    rev = "v0.3.1";
    sha256 = "1c5zfpvm0hrd9lp8rasmw79dnr2aabh0i6y11wzb783bp8m3p2sq";
  };
  configureFlags = old.configureFlags ++ [ "--add-dynamic-module=." ];
  makeFlags = [ "modules" ];
  buildInputs = old.buildInputs ++ [ nginx ];
  postUnpack = ''
    (
      cd source || exit 1
      tar xvf ${nginx.src} --strip-components=1
    )
  '';
  installPhase = ''
    mkdir -p $out/etc/nginx/modules
    cp -v objs/ndk_http_module.so $out/etc/nginx/modules
  '';
  meta = if old.meta != null then old.meta else old.meta // {
    description = "NGINX develkit module";
  };
})
