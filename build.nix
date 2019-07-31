with import <nixpkgs> {};

let
  # TODO: convert to callPackages and non-overlay style? more reliable and usable by others, but can cause more pkg dupe?
  nixpkgsUnstable = lib.filterAttrs (p: v: p != "perlPackages")
    (lib.filterAttrs (p: v: p != "luajitPackages")
      (import
        (import ./nixpkgs/nixpkgs-unstable)
        { overlays = [ (import ./default.nix) ]; }).majordomoPkgs);
in
{
  all = [ nixpkgsUnstable ];
  inherit nixpkgsUnstable;
}

