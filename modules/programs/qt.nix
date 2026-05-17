{ self, inputs, ... }:
{
  flake.modules.nixos.qt =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Themes
        materia-kde-theme
        kdePackages.breeze-icons # Fixed - added kdePackages prefix

        # Qt6 tools (Dolphin is Qt6)
        kdePackages.qt6ct
        kdePackages.qtstyleplugin-kvantum

        # Qt5 tools (for Qt5 apps)
        libsForQt5.qt5ct
        libsForQt5.qtstyleplugin-kvantum

        # Multimedia support
        pipewire

        # Additional KDE components
        kdePackages.kiconthemes
        kdePackages.kcolorscheme
      ];

      qt = {
        enable = true;
        platformTheme = "qt5ct"; # NixOS option only supports qt5ct, not qt6ct
        style = "kvantum";
      };

      environment.sessionVariables = {
        # Override to use qt6ct at runtime (for Qt6 apps like Dolphin)
        QT_QPA_PLATFORMTHEME = "qt5ct";
        QT_STYLE_OVERRIDE = "kvantum";
      };
    };
}
