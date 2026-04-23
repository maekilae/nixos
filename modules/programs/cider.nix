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
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.cider2
      ];

    };
}
