{ self, inputs, ... }:
{
  flake.modules.nixos.hyprland =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      imports = with inputs.self.modules.nixos; [
        gtk
      ];
      services.displayManager.cosmic-greeter.enable = true;
      programs.hyprland = {
        enable = true;
        package = selfpkgs.hyprland;
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
    };
}
