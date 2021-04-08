{ stdenv, makeWrapper, coreutils, gnused, gnugrep, diffutils, nix, git, jq }:

stdenv.mkDerivation rec {
  name = "common-updater-scripts";

  src = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/300846f3c982ffc3e54775fa99b4ec01d56adf65.tar.gz";
    sha256 = "01pv2sdf1x15p4pcl344lpjb3fgf83zq53kbw20hsqyxspp26676";
  };

  patches = [ ./common-updater-scripts-fix-packages-upgrade-in-overlay.patch ];

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -v pkgs/common-updater/scripts/* $out/bin

    for f in $out/bin/*; do
      wrapProgram $f --prefix PATH : ${stdenv.lib.makeBinPath [ coreutils gnused gnugrep nix diffutils git jq ]}
    done
  '';
}
