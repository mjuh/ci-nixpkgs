{ stdenv, fetchFromGitHub, nginx }:

nginx.overrideAttrs(old: rec {
  name = "nginx-vts-module";
  version = "0.1.18";
  src = fetchFromGitHub {
    owner = "vozlt";
    repo = "nginx-module-vts";
    rev = "d6aead19ab52834ad748f14dc536b9128ee22372";
    sha256 = "1jq2s9k7hah3b317hfn9y3g1q4g4x58k209psrfsqs718a9sw8c7";
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
