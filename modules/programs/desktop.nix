{
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos.gnome =
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
        hyprland
        dev
      ];
      modules.dev.enable = true;
      modules.dev.zed.enable = true;
      modules.browser.vivaldi.enable = true;

      environment.systemPackages = with inputs.self.packages."${pkgs.stdenv.hostPlatform.system}"; [
        # quickshell
      ];

      programs.niri.enable = false;
      programs.niri.package = selfpkgs.niri;
    };
}
