{ stdenv, inetutils }:

inetutils.overrideAttrs (_: rec {
  postInstall = ''
    for binary in dnsdomainname hostname ifconfig logger rcp rexec rlogin rsh talk tftp whois; do
      rm -f "$out/bin/$binary";
    done
  '';
})

