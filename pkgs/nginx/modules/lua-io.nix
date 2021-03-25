{ stdenv, fetchFromGitHub, nginx }:

nginx.overrideAttrs(old: rec {
  name = "nginx-io-module";
  version = "0.0.1";
  src = fetchFromGitHub {
    owner = "tokers";
    repo = "lua-io-nginx-module";
    rev = "master";
    sha256 = "04hg1rzljfdcd5jhhbnk8790r273kvxpfq421h2jlzy3pazkhjgy";
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
    cp -v objs/ngx_http_vhost_traffic_status_module.so $out/etc/nginx/modules
  '';
  dontStrip = true;
  meta = if old.meta != null then old.meta else old.meta // {
    description = "NGINX virtual host traffic status module";
  };
})
