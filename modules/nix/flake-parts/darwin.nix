{
  lib,
  flake-parts-lib,
  ...
}:
{
  # currently, there's no nix-darwin module for flake-parts,
  # so we have to manually add flake.nix-darwin

  config.flake-file.inputs = {
    # Release branch must match nixpkgs-darwin (26.05). `master` tracks the
    # latest unstable release and will fail the nix-darwin/Nixpkgs match check.
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  options = {
    flake = flake-parts-lib.mkSubmoduleOptions {
      darwin = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = { };
      };
    };
  };
}
