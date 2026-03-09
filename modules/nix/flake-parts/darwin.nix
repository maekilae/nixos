{
  lib,
  flake-parts-lib,
  ...
}:
{
  # currently, there's no nix-darwin module for flake-parts,
  # so we have to manually add flake.nix-darwin

  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      darwin = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };
    };
  };
}
