{ inputs, ... }:
let
  nvim = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.neovim
    ];
  };
in
{
  flake.modules.nixos.nvim = nvim;
  flake.modules.darwin.nvim = nvim;
}
