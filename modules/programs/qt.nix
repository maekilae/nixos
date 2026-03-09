{ self, inputs, ... }:
{
  flake.modules.nixos.gtk =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      environment.systemPackages = with pkgs; [
        materia-kde-theme
        selfpkgs.hyprqt6engine
      ];
      qt = {
        enable = true;
      };
      environment.sessionVariables = {
        QT_QPA_PLATFORMTHEME = "hyprqt6engine";
      };
    };

}
