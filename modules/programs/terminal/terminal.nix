{ self, ... }:
{
  flake.modules.nixos.terminal =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      environment.systemPackages = [
        selfpkgs.wezterm
      ];
    };
}
