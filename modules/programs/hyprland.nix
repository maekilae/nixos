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
      # services.hypridle = {
      #   enable = true;
      #   package = selfpkgs.hypridle;
      # };
      systemd.user.services.hypridle = {
        enable = true;
        description = "Hyprland's idle daemon";
        wantedBy = [ "hyprland-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = lib.mkForce [
            ""
            "${selfpkgs.hypridle}/bin/hypridle"
          ];
          Restart = "always";
        };
      };
      programs.hyprlock = {
        enable = true;
        package = inputs.hyprwm.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;
      };

      programs.hyprland = {
        enable = true;
        package = selfpkgs.hyprland;
        withUWSM = true;
        xwayland.enable = true;
        portalPackage =
          inputs.hyprwm.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };

    };
}
