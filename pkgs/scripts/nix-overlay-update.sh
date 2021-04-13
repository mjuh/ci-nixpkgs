#!/usr/bin/env bash

# TODO: Add "nix-shell" to PATH environment variable.
export PATH=@git@/bin:"$PATH"

current_commit="$(git rev-parse HEAD)"

exit_hook()
{
    git restore flake.nix
}

trap exit_hook EXIT

# TODO: Replace "*php*" with "*" to update all packages.
for directory in pkgs/*
do
    branch="update-$(basename $directory)-${BUILD_ID:-0}"
    git reset --hard HEAD
    git clean -dfx
    git checkout -b "$branch" "$current_commit"
    rm flake.nix # XXX: Don't call "rm flake.nix" in nix-overlay-update.sh script.
    echo \
        | NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs/archive/300846f3c982ffc3e54775fa99b4ec01d56adf65.tar.gz:nixpkgs-overlays="$PWD" \
                  nix-shell '<nixpkgs/maintainers/scripts/update.nix>' \
                  --arg include-overlays true \
                  --argstr path \
                  "$(basename "$directory")"
    exit_hook
    if nix-shell pkgs/nix-shell --run "nix build .#$(basename $directory) --print-build-logs --show-trace"
    then
        git add --update "$directory"
        git config user.email "jenkins@majordomo.ru"
        git config user.name "jenkins"
        git commit -m "Update packages."
        if [[ "$(git rev-parse HEAD)" != $current_commit  ]]
        then
            git push origin HEAD:refs/heads/"update-$(basename $directory)-${BUILD_ID:-0}"
            printf "\033[32mINFO:\033[0m Package $(basename "$directory") updated successfully.\n"
            @gitlabMergeScript@
        else
            printf "\033[35mWARNING:\033[0m Current commit is the same as before update.\n"
            git branch -D "$branch"
        fi
    fi
done
