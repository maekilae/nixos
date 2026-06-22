{ inputs, ... }:
let
  installNvim = { pkgs, ... }: {
    environment.systemPackages = [
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.neovimDynamic
    ];
  };
in
{
  flake.modules.nixos.nvim = installNvim;
  flake.modules.darwin.nvim = installNvim;
}
