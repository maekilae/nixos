{ self, inputs, ... }:
{
  flake.modules.nixos.terminal =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.system}";
    in
    {
      environment.systemPackages = [
        # pkgs.wezterm
        selfpkgs.wezterm
      ];
    };
}
