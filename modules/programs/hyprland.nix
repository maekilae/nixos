{
  self,
  inputs,
  lib,
  ...
}:
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
      environment.systemPackages = with pkgs; [
        bibata-cursors
      ];
      programs.uwsm.enable = true;
      services.displayManager.cosmic-greeter.enable = true;
      #services.displayManager.sddm = {
      #  enable = true;
      #  theme = "catppuccin-mocha-mauve";
      #  wayland.enable = true;
      #};
      services.hypridle = {
        enable = true;
        package = selfpkgs.hypridle;
      };
      programs.hyprlock.enable = true;

      programs.hyprland = {
        enable = true;
        package = selfpkgs.hyprland;
        withUWSM = true;
        xwayland.enable = true;
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };

    };
}
