{ self, ... }:
{
  flake.modules.nixos.cad =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      environment.systemPackages = with pkgs; [
        freecad
      ];
    };
}
