{ self, ... }:
{
  flake.modules.nixos.terminal =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.system}";
    in
    {
      imports = [ self.wrappers.wezterm ];
      environment.systemPackages = [
        # pkgs.wezterm
        selfpkgs.wezterm
      ];
    };
}
