{ stdenv
, lib
, openssl
, fetchurl
, apr
, aprutil
, perl
, zlib
, nss_ldap
, nss_pam_ldapd
, openldap
, pcre
, nginxModules
}:

with nginxModules;
with lib;

let
  modules = [ nginxLua nginxVts nginxSysGuard develkit ];
in
stdenv.mkDerivation rec {
  name = "nginx-${version}";
  version = "1.16.1";
  src = fetchurl {
    url = "https://nginx.org/download/nginx-${version}.tar.gz";
    sha256 = "0az3vf463b538ajvaq94hsz9ipmjgnamfj1jy0v5flfks5njl77i";
  };
  buildInputs = [ openssl zlib pcre ] ++ concatMap (mod: mod.inputs or []) modules;
  patches = [ ./configure.patch ];
  configureFlags = [
    "--with-http_ssl_module"
    "--with-http_realip_module"
    "--with-http_sub_module"
    "--with-http_gunzip_module"
    "--with-http_gzip_static_module"
    "--with-threads"
    "--with-pcre-jit"
    "--with-file-aio"
    "--with-http_v2_module"
    "--with-http_stub_status_module"
    "--without-http_geo_module"
    "--without-http_empty_gif_module"
    "--without-http_scgi_module"
    "--without-http_grpc_module"
    "--without-http_memcached_module"
    "--without-http_charset_module"
    "--without-select_module"
    "--without-poll_module"
    "--user=root"
    "--error-log-path=/dev/stderr"
    "--http-log-path=/dev/stdout"
    "--pid-path=/run/nginx.pid"
    "--lock-path=/run/nginx.lock"
    "--http-client-body-temp-path=/run/client_body_temp"
    "--http-proxy-temp-path=/run/proxy_temp"
  ] ++ map (mod: "--add-module=${mod.src}") modules; 
  preConfigure = (concatMapStringsSep "\n" (mod: mod.preConfigure or "") modules);
  hardeningEnable = [ "pie" ];
  enableParallelBuilding = true;
  postInstall = ''
      shopt -s extglob
      mv $out/sbin $out/bin
      rm -f $out/conf/!(mime.types)
      rm -rf $out/html
    '';
}
