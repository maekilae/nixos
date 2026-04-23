{ self, inputs, ... }:
{
  flake.modules.nixos.qt =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Themes
        materia-kde-theme
        # breeze-icons

        # Qt configuration tools
        qt6Packages.qt6ct
        qt6Packages.qtstyleplugin-kvantum
        kdePackages.qt6ct

        libsForQt5.qtstyleplugin-kvantum
        libsForQt5.qt5ct
      ];

      qt = {
        enable = true;
        platformTheme = "qt5ct";
        style = "kvantum";
      };

      environment.sessionVariables = {
        QT_QPA_PLATFORMTHEME = "qt5ct";
        QT_STYLE_OVERRIDE = "kvantum";
      };

    };
}
