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
    in
    {

      imports = with inputs.self.modules.nixos; [
        gtk
        fonts
        spotify
        cider
        browser
        hyprland
        terminal
        gaming
        discord
        dev
        filebrowser
        # gnome
      ];
      modules.dev.enable = true;
      modules.dev.zed.enable = true;
      modules.browser.vivaldi.enable = false;
      modules.browser.helium.enable = true;

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
        pavucontrol
      ];

      programs.niri.enable = false;
      programs.niri.package = selfpkgs.niri;
    };
}
