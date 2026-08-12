{
  flake.modules.nixos.qt =
    { pkgs, ... }:
    {
      # `qt.enable` sets QT_PLUGIN_PATH / QML2_IMPORT_PATH across the profile so
      # Qt6 apps (Dolphin, Okular, …) can actually find the qt6ct platform
      # theme and adwaita-qt6 style plugin. Without it, Qt6 apps fall back to a
      # default with no palette and render with a white window / gray text.
      qt = {
        enable = true;
        platformTheme = "qt5ct"; # installs both qt5ct and qt6ct
        style = "adwaita-dark"; # installs both adwaita-qt and adwaita-qt6
      };

      environment.systemPackages = with pkgs; [
        libsForQt5.qtstyleplugin-kvantum
        qt6Packages.qtstyleplugin-kvantum
      ];
    };
}
