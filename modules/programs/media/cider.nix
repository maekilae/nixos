{ inputs, self, ... }:
{
  flake.modules.nixos.cider =
    {
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) mkDefault;
    in
    {
      environment.systemPackages = [
        inputs.anynix.packages.${pkgs.stdenv.hostPlatform.system}.cider
      ];

    };
}
