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
      silent-sddm = pkgs.stdenv.mkDerivation {
        name = "silent-sddm";

        src = pkgs.fetchFromGitHub {
          owner = "uiriansan";
          repo = "SilentSDDM";
          rev = "v1.4.2";
          sha256 = "WeoJBj/PhqFCCJEIycTipqPbKm5BpQT2uzFTYcYZ30I=";
        };

        propagatedUserEnvPkgs = with pkgs.kdePackages; [
          qtsvg
          qtmultimedia
          qtvirtualkeyboard
          qtdeclarative
        ];

        installPhase = ''
          mkdir -p $out/share/sddm/themes/silent
          cp -r * $out/share/sddm/themes/silent/
        '';
      };
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      imports = with inputs.self.modules.nixos; [
        gtk
      ];
      environment.systemPackages = with pkgs; [
        bibata-cursors
        silent-sddm
      ];
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
      programs.uwsm.enable = true;
      services.displayManager.sddm = {
        enable = true;
        wayland = {
          enable = true;
          compositor = "kwin"; # Does not work without this
        };
        theme = "silent";
        package = pkgs.kdePackages.sddm;
        extraPackages = with pkgs; [
          silent-sddm
          kdePackages.qtsvg
          kdePackages.qtmultimedia
          kdePackages.qtvirtualkeyboard
        ];
      };
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
