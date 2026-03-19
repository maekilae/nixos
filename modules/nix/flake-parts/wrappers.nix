{
  lib,
  flake-parts-lib,
  ...
}:
{
  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      wrappers = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };

      wrapperModules = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };
    };
  };
}
