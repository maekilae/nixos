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
      modules.browser.vivaldi.enable = true;

      xdg.portal = {
        enable = true;
      };

      environment.systemPackages = with pkgs; [
        inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
        # inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.affinity
      ];

      programs.niri.enable = false;
      programs.niri.package = selfpkgs.niri;
    };
}
