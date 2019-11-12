{ stdenv, pkgs, postfix }:

postfix.overrideAttrs (oldAttrs: {
  postInstall = oldAttrs.postInstall or "" + ''
    echo 'command_directory=/run/bin' > $out/etc/postfix/main.cf
  '';
})
