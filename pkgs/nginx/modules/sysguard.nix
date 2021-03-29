{ stdenv, fetchFromGitHub, nginx }:

nginx.overrideAttrs(old: rec {
  name = "nginx-sysguard-module";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "vozlt";
    repo = "nginx-module-sysguard";
    rev = "e512897f5aba4f79ccaeeebb51138f1704a58608";
    sha256 = "19c6w6wscbq9phnx7vzbdf4ay6p2ys0g7kp2rmc9d4fb53phrhfx";
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
    cp -v objs/ngx_http_sysguard_module.so $out/etc/nginx/modules
  '';
  meta = if old.meta != null then old.meta else old.meta // {
    description = "NGINX sysguard module";
  };
})
