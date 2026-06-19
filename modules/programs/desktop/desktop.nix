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
        theming
        media
        compositor
        browser
        terminal
        gaming
        discord
        dev
        filebrowser
        cad
        editor
        # desktopEnv
        # editor
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
        inputs.anynix.packages.${pkgs.stdenv.hostPlatform.system}.affinity
        qalculate-qt
        pavucontrol
      ];

      programs.niri.enable = false;
      programs.niri.package = selfpkgs.niri;
    };
}
