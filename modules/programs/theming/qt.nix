{ inputs, ... }:
{
  flake.modules.nixos.qt =
    { pkgs, lib, ... }:
    let
      # Build hyprqt6engine against THIS flake's qtbase / hyprlang / hyprutils
      # rather than the pinned versions from hyprqt6engine's own flake input.
      # Qt rejects plugins whose build-time qtbase differs from the running
      # qtbase (silent load failure). Also:
      #   * fix `PLUGINDIR` so plugins land in `lib/qt-6/plugins/` (upstream
      #     installs into `lib/qt-6/`, which Qt does not scan by default);
      #   * patch CMakeLists to require `Qt6::Widgets`/`Qt6::WidgetsPrivate` +
      #     `KF6::IconThemes` — CMake makes these optional, and without them
      #     the plugin's `create()` compiles out the palette/QApplication code
      #     path and returns without ever installing a QPalette, which is why
      #     Qt fell through to the "generic" theme (light) despite the plugin
      #     being discovered.
      hyprqt6engine =
        (pkgs.callPackage "${inputs.hyprqt6engine}/nix/default.nix" {
          stdenv = pkgs.gcc15Stdenv;
          version = "0.1.0";
        }).overrideAttrs
          (old: {
            buildInputs = (old.buildInputs or [ ]) ++ [
              pkgs.kdePackages.kiconthemes
            ];
            postPatch = (old.postPatch or "") + ''
              substituteInPlace hyprqtplugin/CMakeLists.txt \
                --replace-fail \
                  'find_package(Qt6 REQUIRED COMPONENTS Gui GuiPrivate)' \
                  'find_package(Qt6 REQUIRED COMPONENTS Gui GuiPrivate Widgets WidgetsPrivate)
              find_package(KF6IconThemes REQUIRED)'
            '';
            cmakeFlags = lib.mapAttrsToList lib.cmakeFeature {
              PLUGINDIR = "${placeholder "out"}/lib/qt-6/plugins";
            };
          });
    in
    {
      # `qt.enable` populates QT_PLUGIN_PATH / QML2_IMPORT_PATH so Qt6 discovers
      # plugins from all system-profile packages. `qt.style` installs the Breeze
      # widget style (used by hyprqt6engine's `style = Breeze`) and pins
      # QT_STYLE_OVERRIDE. We DON'T set `qt.platformTheme` — hyprqt6engine is
      # the platform theme, wired via QT_QPA_PLATFORMTHEME below.
      qt = {
        enable = true;
        style = "breeze";
      };

      environment.variables.QT_QPA_PLATFORMTHEME = "hyprqt6engine";

      environment.systemPackages = [ hyprqt6engine ];

      # hyprqt6engine reads its config from XDG_CONFIG_DIRS/hypr or /etc/hypr.
      # Point it at Breeze's BreezeDark color scheme (surfaced in the system
      # profile via the pathsToLink entry below).
      environment.etc."xdg/hypr/hyprqt6engine.conf".text = ''
        theme {
            color_scheme = /run/current-system/sw/share/color-schemes/BreezeDark.colors
            icon_theme = breeze-dark
            style = Breeze
        }

        misc {
            single_click_activate = 0
            menus_have_icons = 1
            shortcuts_for_context_menus = 1
        }
      '';

      # Kept: KDE apps read `kdeglobals` directly for KColorScheme resolution
      # regardless of the Qt platform theme. Keeping the color scheme name +
      # widget style in sync so KColorScheme::View and QApplication::palette
      # agree.
      environment.etc."xdg/kdeglobals".text = ''
        [General]
        ColorScheme=BreezeDark
        Name=Breeze Dark

        [KDE]
        widgetStyle=Breeze

        [Icons]
        Theme=breeze-dark
      '';

      # NixOS's default `environment.pathsToLink` doesn't include these paths,
      # so `.colors` files and LookAndFeel packages installed by system
      # packages don't surface in XDG_DATA_DIRS. Without this, hyprqt6engine's
      # `color_scheme = …/BreezeDark.colors` above resolves to a nonexistent
      # path and KColorScheme lookups silently fall back to Breeze Light.
      environment.pathsToLink = [
        "/share/color-schemes"
        "/share/plasma"
      ];
    };
}
