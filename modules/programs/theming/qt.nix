{ self, inputs, ... }:
{
  flake.modules.nixos.qt =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Themes
        materia-kde-theme
        kdePackages.breeze
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

      # KDE apps (Dolphin, Ark, …) load row/text colors from KColorScheme,
      # which reads kdeglobals — Kvantum does not control these. Without
      # this file, KColorScheme falls back to Breeze Light → white Base,
      # light-gray AlternateBase, black text (unreadable in dark sessions).
      environment.etc."xdg/kdeglobals".text = ''
        [General]
        ColorScheme=BreezeDark
        Name=Breeze Dark
        shadeSortColumn=true

        [ColorEffects:Disabled]
        Color=56,56,56
        ColorAmount=0
        ColorEffect=0
        ContrastAmount=0.65
        ContrastEffect=1
        IntensityAmount=0.1
        IntensityEffect=2

        [ColorEffects:Inactive]
        ChangeSelectionColor=true
        Color=112,111,110
        ColorAmount=0.025
        ColorEffect=2
        ContrastAmount=0.1
        ContrastEffect=2
        Enable=false
        IntensityAmount=0
        IntensityEffect=0

        [Colors:Button]
        BackgroundAlternate=30,87,116
        BackgroundNormal=49,54,59
        DecorationFocus=61,174,233
        DecorationHover=61,174,233
        ForegroundActive=61,174,233
        ForegroundInactive=161,169,177
        ForegroundLink=29,153,243
        ForegroundNegative=218,68,83
        ForegroundNeutral=246,116,0
        ForegroundNormal=252,252,252
        ForegroundPositive=39,174,96
        ForegroundVisited=155,89,182

        [Colors:Complementary]
        BackgroundAlternate=30,87,116
        BackgroundNormal=42,46,50
        DecorationFocus=61,174,233
        DecorationHover=61,174,233
        ForegroundActive=61,174,233
        ForegroundInactive=161,169,177
        ForegroundLink=29,153,243
        ForegroundNegative=218,68,83
        ForegroundNeutral=246,116,0
        ForegroundNormal=252,252,252
        ForegroundPositive=39,174,96
        ForegroundVisited=155,89,182

        [Colors:Header]
        BackgroundAlternate=42,46,50
        BackgroundNormal=49,54,59
        DecorationFocus=61,174,233
        DecorationHover=61,174,233
        ForegroundActive=61,174,233
        ForegroundInactive=161,169,177
        ForegroundLink=29,153,243
        ForegroundNegative=218,68,83
        ForegroundNeutral=246,116,0
        ForegroundNormal=252,252,252
        ForegroundPositive=39,174,96
        ForegroundVisited=155,89,182

        [Colors:Selection]
        BackgroundAlternate=30,87,116
        BackgroundNormal=61,174,233
        DecorationFocus=61,174,233
        DecorationHover=61,174,233
        ForegroundActive=252,252,252
        ForegroundInactive=239,240,241
        ForegroundLink=253,188,75
        ForegroundNegative=176,55,69
        ForegroundNeutral=198,92,0
        ForegroundNormal=252,252,252
        ForegroundPositive=23,104,57
        ForegroundVisited=155,89,182

        [Colors:Tooltip]
        BackgroundAlternate=42,46,50
        BackgroundNormal=49,54,59
        DecorationFocus=61,174,233
        DecorationHover=61,174,233
        ForegroundActive=61,174,233
        ForegroundInactive=161,169,177
        ForegroundLink=29,153,243
        ForegroundNegative=218,68,83
        ForegroundNeutral=246,116,0
        ForegroundNormal=252,252,252
        ForegroundPositive=39,174,96
        ForegroundVisited=155,89,182

        [Colors:View]
        BackgroundAlternate=35,38,41
        BackgroundNormal=27,30,32
        DecorationFocus=61,174,233
        DecorationHover=61,174,233
        ForegroundActive=61,174,233
        ForegroundInactive=161,169,177
        ForegroundLink=29,153,243
        ForegroundNegative=218,68,83
        ForegroundNeutral=246,116,0
        ForegroundNormal=252,252,252
        ForegroundPositive=39,174,96
        ForegroundVisited=155,89,182

        [Colors:Window]
        BackgroundAlternate=49,54,59
        BackgroundNormal=42,46,50
        DecorationFocus=61,174,233
        DecorationHover=61,174,233
        ForegroundActive=61,174,233
        ForegroundInactive=161,169,177
        ForegroundLink=29,153,243
        ForegroundNegative=218,68,83
        ForegroundNeutral=246,116,0
        ForegroundNormal=252,252,252
        ForegroundPositive=39,174,96
        ForegroundVisited=155,89,182

        [WM]
        activeBackground=49,54,59
        activeBlend=252,252,252
        activeForeground=252,252,252
        inactiveBackground=42,46,50
        inactiveBlend=161,169,177
        inactiveForeground=161,169,177
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
