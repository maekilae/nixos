{
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
      helium = inputs.helium.${pkgs.stdenv.hostPlatform.system}.nixosModules.default;
    in
    {

      imports = with inputs.self.modules.nixos; [
        gtk
        fonts
        spotify
        browser
        hyprland
        terminal
        gaming
        discord
        dev
        # gnome
      ];
      modules.dev.enable = true;
      modules.dev.zed.enable = true;
      modules.browser.vivaldi.enable = false;
      modules.browser.helium.enable = false;

      programs.helium = {
        enable = true;
        enableWidevine = true;
        extensions = [
          "ghmbeldphafepmbegfdlkpapadhbakde" # Proton-pass
          "jplgfhpmjnbigmhklmmbgecoobifkmpa" # Proton-VPN
        ];
      };

      xdg.portal = {
        enable = true;
        extraPortals = [
          pkgs.kdePackages.xdg-desktop-portal-kde
        ];
      };

      environment.systemPackages = with pkgs; [
        inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.affinity
        qalculate-qt
      ];

      programs.niri.enable = false;
      programs.niri.package = selfpkgs.niri;
    };
}
