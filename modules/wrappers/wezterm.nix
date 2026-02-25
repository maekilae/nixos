{
  self,
  inputs,
  ...
}:

{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      # packages.wezterm = self'.packages.wezterm;
      packages.wezterm =
        (self.wrapperModules.wezterm.apply {
          inherit pkgs;
          settings = {
            enable_audio_bell = "no";

            font_size = 15;
            font_family = "JetBrainsMono Nerd Font";

            cursor_text_color = "background";

            allow_remote_control = "yes";
            shell_integration = "enabled";

            cursor_trail = 3;

            map = [
              "alt+1 goto_tab 1"
              "alt+2 goto_tab 2"
              "alt+3 goto_tab 3"
              "alt+4 goto_tab 4"
              "alt+5 goto_tab 5"
              "alt+6 goto_tab 6"
              "alt+7 goto_tab 7"
              "alt+8 goto_tab 8"
              "alt+9 goto_tab 9"
              "ctrl+shift+w close_tab"
              "ctrl+t new_tab_with_cwd"
              "ctrl+shift+t new_tab"
            ];

          };
        }).wrapper;
    };

  flake.wrapperModules.wezterm = inputs.wrappers.lib.wrapModule (
    {
      config,
      wlib,
      lib,
      ...
    }:
    let
      inherit (lib) mkOption types;
      inherit (lib.generators) mkKeyValueDefault;
      weztermKeyValueFormat = config.pkgs.formats.keyValue {
        listsAsDuplicateKeys = true;
        mkKeyValue = mkKeyValueDefault { } " ";
      };
      writeWeztermConfig = cfg: weztermKeyValueFormat.generate "wezterm.lua" cfg;
    in
    {
      options = {
        settings = mkOption {
          type = weztermKeyValueFormat.type;
          default = { };
        };

        extraConfig = mkOption {
          type = types.str;
          default = "";
        };

        configFile = mkOption {
          type = wlib.types.file config.pkgs;
          default.path = toString (writeWeztermConfig config.settings) + config.extraConfig;
        };
      };

      config = {
        package = config.pkgs.wezterm;

        flags = {
          "--config-file" = config.configFile.path;
        };
      };
    }
  );
}
