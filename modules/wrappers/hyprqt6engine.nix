{
  inputs,
  self,
  ...
}:
{
  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    {
      packages.hyprqt6engine =
        (self.wrapperModules.hyprqt6engine.apply {
          inherit pkgs;
          # Example usage of your new options
          color_scheme = "materia-kde-theme";
          icon_theme = "Flat-Remix-Blue-Light";
          style = "kvantum-dark";
          font_fixed = "JetBrains Mono";
          font_fixed_size = 11;
          font = "Inter";
          font_size = 11;
        }).wrapper;
    };

  flake.wrapperModules.hyprqt6engine = inputs.wrappers.lib.wrapModule (
    {
      config,
      lib,
      # Removed pkgs from here
      ...
    }:
    let
      generatedConfig = ''
        color_scheme=${config.color_scheme}
        icon_theme=${config.icon_theme}
        style=${config.style}
        font_fixed=${config.font_fixed}
        font_fixed_size=${builtins.toString config.font_fixed_size}
        font=${config.font}
        font_size=${builtins.toString config.font_size}
      '';

      writeEngineConfig = cfg: config.pkgs.writeText "hyprqt6engine.conf" cfg;
      configFilePath = "${writeEngineConfig generatedConfig}";

      # Use config.pkgs instead of just pkgs
      hyprqt6engine = inputs.hyprqt6engine.packages.${config.pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      options = {
        color_scheme = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "The full path to a color scheme. Can be a qt6ct theme, or a KColorScheme. Leave empty for defaults.";
        };

        icon_theme = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Name of an icon theme to use.";
        };

        style = lib.mkOption {
          type = lib.types.str;
          default = "Fusion";
          description = "Widget style to use, e.g. Fusion or kvantum-dark.";
        };

        font_fixed = lib.mkOption {
          type = lib.types.str;
          default = "JetBrains Mono";
          description = "Font family for the fixed width font.";
        };

        font_fixed_size = lib.mkOption {
          type = lib.types.int;
          default = 11;
          description = "Font size for the fixed width font.";
        };

        font = lib.mkOption {
          type = lib.types.str;
          default = "Inter";
          description = "Font family for the regular font.";
        };

        font_size = lib.mkOption {
          type = lib.types.int;
          default = 11;
          description = "Font size for the regular font.";
        };
      };

      config = {
        flags = {
          "--config" = "${configFilePath}";
        };

        package = hyprqt6engine;
      };
    }
  );
}
