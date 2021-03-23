## TODO

- [ ] Replace shell timeout in nixFetchSrcCmd Jenkinsfile.
- [ ] Replace Google Chrome in NGINX tests to Firefox or something else.

# Nix packages overlay

[Nix](https://nixos.org/) overlay used in most of our projects.

## Prerequisites

Before you begin, ensure you have met the following requirements:

* You have a `<Linux/Mac>` machine.
* You have installed the latest version of [Nix package manager](https://nixos.org/).

## Building

### Package

To build a specific package:
```
nix build .#php74
```

### Container

TODO via flakes

## Using overlay to build a Docker container

To build a Docker container, clone one of webservices Git repository
and follow README.md inside.

## Upgrading overlay packages

To upgrade a package, for example php56, run the following command inside
Overlay Git repository:

``` shell
NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs/archive/300846f3c982ffc3e54775fa99b4ec01d56adf65.tar.gz:nixpkgs-overlays=$PWD nix-shell '<nixpkgs/maintainers/scripts/update.nix>' --arg include-overlays true --argstr path php56
```

See `nix --help` inside nix-shell for additional information.

## Contributing to Nix packages overlay

To contribute to Nix packages overlay, follow these steps:

1. Fork this repository.
2. Create a branch: `git checkout -b <branch_name>`.
3. Make your changes and commit them: `git commit -m '<commit_message>'`
4. Push to the original branch: `git push origin <project_name>/<location>`
5. Create the pull request.

## Contact

If you want to contact me you can reach us at <support@majordomo.ru>.

## License

This project uses the following license: [GPL3+](https://www.gnu.org/licenses/gpl-3.0.en.html).
