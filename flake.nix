{
  description = "Majordomo overlay flake";

  inputs.nixpkgs = { url = "github:NixOS/nixpkgs/19.09"; flake = false; };
  inputs.nixpkgs-stable = { url = "nixpkgs/nixos-20.09"; };
  inputs.nixpkgs-deprecated = { url = "github:NixOS/nixpkgs?ref=15.09"; flake = false; };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-deprecated }:
    let
      system = "x86_64-linux";
      majordomoOverlay = import ./.;
      majordomoOverlayed = import nixpkgs {
        inherit system;
        overlays = [ majordomoOverlay ];
      };
      majordomoJustOverlayed = (majordomoOverlay { } majordomoOverlayed);
      majordomoJustOverlayedPackages =
        removeAttrs majordomoJustOverlayed majordomoOverlayed.notDerivations;
    in {
      nixpkgs = majordomoOverlayed;
      deploy = { registry ? "docker-registry.intr", tag }:
        with nixpkgs-stable.legacyPackages.x86_64-linux; writeScriptBin "deploy" ''
            #!${bash}/bin/bash -e
            set -x
            if [[ -z $GIT_BRANCH ]]
            then
                GIT_BRANCH="$(${git}/bin/git branch --show-current)"
            fi
            image="${registry}/${tag}:$GIT_BRANCH"
            ${skopeo}/bin/skopeo copy docker-archive:"$(nix path-info .#container)" \
                docker-daemon:"$image" --insecure-policy
            ${docker}/bin/docker push "$image"
          '';
      packages.x86_64-linux = majordomoJustOverlayedPackages // {
        union = with majordomoOverlayed;
          let inherit (lib) collect isDerivation;
          in callPackage ({ stdenv }:
            stdenv.mkDerivation {
              name = "majordomo-packages-union";
              buildInputs = lib.filter (package: lib.isDerivation package)
                (collect isDerivation majordomoJustOverlayedPackages);
              buildPhase = false;
            }) { };
        sources = with majordomoOverlayed;
          let inherit (lib) collect isDerivation;
          in callPackage ({ stdenv }:
            let
              packages = (map (package: package.src)
                (lib.filter (package: lib.hasAttrByPath [ "src" ] package)
                  (collect isDerivation majordomoJustOverlayedPackages)));
            in stdenv.mkDerivation {
              name = "sources";
              builder = writeScript "builder.sh" (''
                source $stdenv/setup
                for package in ${builtins.concatStringsSep " " packages};
                do
                    echo "$package" >> $out
                done
              '');
            }) { };
        check =
          with nixpkgs-stable.legacyPackages.x86_64-linux; writeScriptBin "check" ''
            #!${bash}/bin/bash -e
            ${shellcheck}/bin/shellcheck ${self.outputs.deploy { tag = "example/latest"; }}/bin/deploy
          '';
        phantomjs = with import nixpkgs-deprecated { inherit system; }; (rec {
          libjpeg8 = callPackage ./pkgs/libjpeg8 {};
          phantomjs = callPackage ./pkgs/mj-phantomjs/default.nix {
            inherit libjpeg8;
            icu52 = icu;
            gcc-unwrapped = with import nixpkgs { inherit system; }; gcc-unwrapped;
          };
        }).phantomjs;
      };
      defaultPackage.x86_64-linux = self.packages.x86_64-linux.union;
    };
}
