{ self, inputs, ... }:
{
  flake.modules.nixos.hyprland =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      programs.hyprland = {
        enable = true;
        # set the flake package
        package = selfpkgs.hyprland;
        # make sure to also set the portal package, so that they are in sync
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
    };
}
