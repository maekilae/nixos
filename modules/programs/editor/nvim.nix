{ inputs, ... }:
{
  flake.modules.nixos.nvim =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.neovimDynamic
      ];
    };
}
