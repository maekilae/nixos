{ self, inputs, ... }:
{
  flake.modules.nixos.qt =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Themes
        materia-kde-theme
        kdePackages.breeze-icons

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
        # NixOS option only accepts qt5ct in this channel — env vars below
        # override to qt6ct at runtime so Qt6 apps actually load libqt6ct.so.
        platformTheme = "qt5ct";
        style = "kvantum";
      };

      environment.variables = {
        QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
        QT_STYLE_OVERRIDE = "kvantum";
      };

      # Tell Kvantum which actual theme to render. Without this file Kvantum
      # has no theme picked and Qt apps look unstyled even with
      # style=kvantum-dark set in qt5ct/qt6ct.
      environment.etc."xdg/Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=MateriaDark
      '';

      # System-wide qt5ct defaults. User-level
      # ~/.config/qt5ct/qt5ct.conf overrides this if present.
      environment.etc."xdg/qt5ct/qt5ct.conf".text = ''
        [Appearance]
        custom_palette=false
        icon_theme=Flat-Remix-Blue-Light
        standard_dialogs=default
        style=kvantum-dark

        [Fonts]
        fixed="JetBrains Mono,11,-1,5,50,0,0,0,0,0"
        general="Inter,11,-1,5,50,0,0,0,0,0"

        [Interface]
        activate_item_on_single_click=1
        buttonbox_layout=0
        cursor_flash_time=1000
        dialog_buttons_have_icons=1
        double_click_interval=400
        gui_effects=@Invalid()
        keyboard_scheme=2
        menus_have_icons=true
        show_shortcuts_in_context_menus=true
        stylesheets=@Invalid()
        toolbutton_style=4
        underline_shortcut=1
        wheel_scroll_lines=3

        [Troubleshooting]
        force_raster_widgets=1
        ignored_applications=@Invalid()
      '';

      # System-wide qt6ct defaults for Qt6 apps (Dolphin, Qalculate-Qt, …).
      environment.etc."xdg/qt6ct/qt6ct.conf".text = ''
        [Appearance]
        custom_palette=false
        icon_theme=Flat-Remix-Blue-Light
        standard_dialogs=default
        style=kvantum-dark

        [Fonts]
        fixed="JetBrains Mono,11,-1,5,50,0,0,0,0,0"
        general="Inter,11,-1,5,50,0,0,0,0,0"

        [Interface]
        activate_item_on_single_click=1
        buttonbox_layout=0
        cursor_flash_time=1000
        dialog_buttons_have_icons=1
        double_click_interval=400
        gui_effects=@Invalid()
        keyboard_scheme=2
        menus_have_icons=true
        show_shortcuts_in_context_menus=true
        stylesheets=@Invalid()
        toolbutton_style=4
        underline_shortcut=1
        wheel_scroll_lines=3

        [Troubleshooting]
        force_raster_widgets=1
        ignored_applications=@Invalid()
      '';
    };
}
