{
  flake.modules.nixos.qt =
    { pkgs, ... }:
    {
      # 1. Install Qt theme engine & config tools
      environment.systemPackages = with pkgs; [
        libsForQt5.qt5ct # for Qt5 apps
        kdePackages.qt6ct # for Qt6 apps
        libsForQt5.qtstyleplugin-kvantum # optional, nicer theming engine
        adwaita-qt # a simple dark-capable style
        adwaita-qt6
      ];

      # 2. Globally force the platform theme and style override
      environment.sessionVariables = {
        QT_QPA_PLATFORMTHEME = "qt5ct";
        QT_STYLE_OVERRIDE = "adwaita-dark";
      };
    };
}
