{
  description = "Majordomo overlay flake";

  inputs.nixpkgs = {
    url = "github:NixOS/nixpkgs/19.09";
    flake = false;
  };
  inputs.nixpkgs-stable = { url = "nixpkgs/nixos-20.09"; };
  inputs.nixpkgs-deprecated = {
    url = "github:NixOS/nixpkgs?ref=15.09";
    flake = false;
  };
  inputs.nixpkgs-php81.url = "nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  inputs.shared-http-errors = {
    url = "git+https://gitlab.intr/shared/http_errors.git";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-stable
    , nixpkgs-deprecated
    , nixpkgs-unstable
    , nixpkgs-php81
    , shared-http-errors
    , ...
    }@inputs:
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
      pkgs-unstable = import nixpkgs-unstable { inherit system; };
      inherit (pkgs-unstable.lib) foldl' mergeAttrs;
    in
    {
      overlay = final: prev:
        foldl' mergeAttrs { } [
          (import ./default.nix final prev)

          {
            inherit (majordomoOverlayed) mariadbConnectorC;
          }

          self.packages.${system}
        ];
      nixpkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      };
      deploy =
        { registry ? "docker-registry.intr"
        , tag
        , impure ? false
        , pkg_name ? "container"
        , suffix ? ""
        }:
          with nixpkgs-stable.legacyPackages.x86_64-linux;
          writeScriptBin "deploy" ''
            #!${bash}/bin/bash -e
            set -x

            TAG_SUFFIX=${suffix}

            if [[ -z $GIT_BRANCH ]]
            then
                GIT_BRANCH="$(${git}/bin/git branch --show-current)"
            fi
            archive="$(nix path-info .#${pkg_name} ${
              if impure then "--impure" else ""
            })"
            for image in "${registry}/${tag}:$(git rev-parse HEAD | cut -c -8)$TAG_SUFFIX"
            do
                if ! skopeo inspect --config docker://$image
                then
                    ${skopeo}/bin/skopeo copy docker-archive:"$archive" \
                        docker-daemon:"$image"
                    ${docker}/bin/docker push "$image"
                fi
            done
            for image in "${registry}/${tag}:$GIT_BRANCH$TAG_SUFFIX"
            do
                ${skopeo}/bin/skopeo copy docker-archive:"$archive" \
                    docker-daemon:"$image"
                ${docker}/bin/docker push "$image"
            done
            if [[ $GIT_BRANCH == master ]]
            then
                image="${registry}/${tag}:latest$TAG_SUFFIX"
                ${skopeo}/bin/skopeo copy docker-archive:"$archive" \
                    docker-daemon:"$image"
                ${docker}/bin/docker push "$image"
            fi
          '';

      packages.x86_64-linux = foldl' mergeAttrs { } [

        majordomoJustOverlayedPackages

        {
          inherit (majordomoJustOverlayed) mjperl5Packages;
          inherit (shared-http-errors.packages.${system}) mj-http-error-pages;
        }

        {
          union = with majordomoOverlayed;
            let inherit (lib) collect isDerivation;
            in
            callPackage
              ({ stdenv, lib }:
                stdenv.mkDerivation rec {
                  name = "majordomo-packages-union";
                  buildInputs = lib.filter (package: lib.isDerivation package)
                    (collect isDerivation majordomoJustOverlayedPackages);
                  buildPhase = false;
                  src = ./.;
                  installPhase = ''
                    cat > $out <<'EOF'
                    ${lib.concatStringsSep "\n" buildInputs}
                    EOF
                  '';
                })
              { inherit lib; };

          sources = with majordomoOverlayed;
            let inherit (lib) collect isDerivation;
            in
            callPackage
              ({ stdenv }:
                let
                  packages = (map (package: package.src)
                    (lib.filter (package: lib.hasAttrByPath [ "src" ] package)
                      (collect isDerivation majordomoJustOverlayedPackages)));
                in
                stdenv.mkDerivation {
                  name = "sources";
                  builder = writeScript "builder.sh" (
                    ''
                      source $stdenv/setup
                      for package in ${builtins.concatStringsSep " " packages};
                      do
                          echo "$package" >> $out
                      done
                    ''
                  );
                })
              { };

        }

        (with majordomoOverlayed; rec {
          inherit (({ pkgs }: rec {
            cacert = callPackage ./pkgs/nss-certs { cacert = pkgs.cacert; };
            parser3 = callPackage ./pkgs/parser { inherit cacert; };
            clamchk = callPackage ./pkgs/clamchk { inherit cacert; };
          }) { inherit pkgs; })
            parser3 clamchk;
        })

        (with majordomoOverlayed; rec {
          nss-certs = callPackage ./pkgs/nss-certs { inherit cacert; };
          postfix = callPackage ./pkgs/postfix { };
          postfixDeprecated = callPackage ./pkgs/postfix-deprecated { };
        })

        (with (import nixpkgs-stable { inherit system; });
        {
          inherit nginx;
          nginx-lua-module = callPackage pkgs/nginx/modules/lua.nix { };
          nginx-vts-module = callPackage pkgs/nginx/modules/vts.nix { };
          nginx-sys-guard-module =
            callPackage pkgs/nginx/modules/sysguard.nix { };
          nginx-lua-io-module = callPackage pkgs/nginx/modules/lua-io.nix { };
        } // (
          let lua51Packages = (import ./pkgs/lua/default.nix);
          in
          {
            luaRestyJwt = callPackage lua51Packages.luaRestyJwt { };
            luaRestyString = callPackage lua51Packages.luaRestyString { };
            luaRestyHmac = callPackage lua51Packages.luaRestyHmac { };
            luaCrypto = callPackage lua51Packages.luaCrypto { };
            luaRestyExec = callPackage lua51Packages.luaRestyExec { };
            netstringLua = callPackage lua51Packages.netstringLua { };
            luaRestyJitUuid = callPackage lua51Packages.luaRestyJitUuid { };
            lua-resty-lrucache =
              callPackage lua51Packages.lua-resty-lrucache { };
            lua-resty-core = callPackage lua51Packages.lua-resty-core { };
            penlight = callPackage lua51Packages.penlight { };
            lua-lfs = callPackage lua51Packages.lua-lfs { };
            lua-cjson = callPackage lua51Packages.lua-cjson { };
            lua-resty-http = callPackage lua51Packages.lua-resty-http { };
          }
        ))

        (with nixpkgs-unstable.legacyPackages.${system}; rec {
          apacheHttpd = callPackage ./pkgs/apacheHttpd { };
          apacheHttpdSSL = callPackage ./pkgs/apacheHttpd { sslSupport = true; };
          apacheHttpdmpmITK = callPackage ./pkgs/apacheHttpdmpmITK { };
          php80 = callPackage ./pkgs/php80 { postfix = callPackage ./pkgs/sendmail { }; };
          iotop-c = callPackage ./pkgs/iotop-c { };
          codenarc = callPackage ./pkgs/codenarc { };
          inherit (import ./pkgs/php-packages/php80.nix {
            inherit lib pkgconfig fontconfig fetchgit imagemagick libmemcached
              memcached pcre2 rrdtool zlib;
            buildPhp80Package = args:
              (import ./pkgs/lib { inherit pkgs; }).buildPhpPackage ({
                php = php80;
                imagemagick = imagemagickBig;
              } // args);
          }) php80-imagick php80-memcached php80-redis php80-rrd php80-timezonedb;
        })

        (with nixpkgs-php81.legacyPackages.${system};
        rec {
          php81 = callPackage ./pkgs/php81 { postfix = majordomoOverlayed.sendmail; };
        } // (import ./pkgs/php-packages/php81.nix {
          inherit lib pkgconfig fontconfig fetchgit imagemagick libmemcached
            memcached pcre2 rrdtool zlib;
          buildPhp81Package = args:
            (import ./pkgs/lib { inherit pkgs; }).buildPhpPackage ({
              php = self.packages.${system}.php81;
              imagemagick = imagemagickBig;
            } // args);
        }))

      ];

      defaultPackage.${system} = self.packages.${system}.union;

      devShell.x86_64-linux = with pkgs-unstable;
        mkShell { buildInputs = [ nixUnstable ]; };

      checks.${system} = {
        deploy = with nixpkgs-stable.legacyPackages.x86_64-linux;
          runCommandNoCC "check-deploy" { } ''
            #!${bash}/bin/bash -e
            exec &> >(tee "$out")
            ${shellcheck}/bin/shellcheck ${
              self.outputs.deploy { tag = "example/latest"; }
            }/bin/deploy
          '';
      };
    };
}
