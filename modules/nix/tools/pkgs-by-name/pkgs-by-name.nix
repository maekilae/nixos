{
  inputs,
  withSystem,
  ...
}:
{

  flake.modules.generic.pkgsByName =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        inputs.self.overlays.default
      ];
    };

}
