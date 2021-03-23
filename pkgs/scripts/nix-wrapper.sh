#!/usr/bin/env bash

help_main()
{
    echo "\

Extra available commands:
  refresh          upgrade package version and hash
"
}

case "$1" in
    refresh)
        nix-shell '<nixpkgs/maintainers/scripts/update.nix>' --arg include-overlays true --argstr path "$2"
        ;;
    --help|-h)
        command nix --help
        help_main
        ;;
    *)
        command nix "$@"
        ;;
esac

