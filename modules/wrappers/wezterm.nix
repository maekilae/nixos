{
  self,
  inputs,
  pkgs,
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
            plugins = {
              "smart_splits" = "https://github.com/mrjones2014/smart-splits.nvim";
              "tabline" = "https://github.com/michaelbrusegard/tabline.wez";
              "vague" = "https://github.com/maekilae/vague-wezterm";
            };
            fontSize = 14.0;
            fontFamily = "JetBrains Mono";
            fontWeight = "Bold";
          };
          extraConfig = ''
            config.term = "xterm-256color"
            config.colors = vague.colors()
            config.window_frame = vague.window_frame()
            config.window_background_opacity = 1

            config.max_fps = 240

            local padding = 20
            config.window_padding = {
                left = padding * 1.5,
                bottom = padding,
                top = padding,
                right = padding * 1.5,
            }

            config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 }
            config.keys = {
                {
                    key = "-",
                    mods = "LEADER",
                    action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } }
                },
                {
                    key = "\\",
                    mods = "LEADER",
                    action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } }
                },
                {
                    key = "c",
                    mods = "LEADER",
                    action = wezterm.action.SpawnTab("CurrentPaneDomain"),
                },
                {
                    key = "p",
                    mods = "LEADER",
                    action = wezterm.action.ActivateTabRelative(-1),
                },
                {
                    key = "n",
                    mods = "LEADER",
                    action = wezterm.action.ActivateTabRelative(1),
                },
                {
                    key = "&",
                    mods = "LEADER|SHIFT",
                    action = wezterm.action { CloseCurrentTab = { confirm = true } }
                },
                {
                    key = "x",
                    mods = "LEADER",
                    action = wezterm.action { CloseCurrentPane = { confirm = true } }
                },
                {
                    key = "z",
                    mods = "LEADER",
                    action = "TogglePaneZoomState"
                },

            }

            config.enable_tab_bar = true
            config.tab_bar_at_bottom = true
            config.use_fancy_tab_bar = false
            config.show_new_tab_button_in_tab_bar = false

            config.window_close_confirmation = "NeverPrompt"
            config.window_decorations = "RESIZE"

            for i = 1, 9 do
                table.insert(config.keys, {
                    key = tostring(i),
                    mods = "LEADER",
                    action = wezterm.action.ActivateTab(i - 1),
                })
            end
            smart_splits.apply_to_config(config, {
                direction_keys = { 'h', 'j', 'k', 'l' },
                modifiers = {
                    move = 'CTRL',         -- modifier to use for pane movement, e.g. CTRL+h to move left
                    resize = 'CTRL|SHIFT', -- modifier to use for pane resize, e.g. META+h to resize to the left
                },
                log_level = 'info',
            })
            tabline.setup({
                options = {
                    icons_enabled = true,
                    theme_overrides = {
                        normal_mode = {
                            a = { fg = "#141415", bg = "#7fa563" },
                            b = { fg = "#7fa563", bg = "#252530" },
                            c = { fg = "#cdcdcd", bg = "#141415" },
                        },
                        copy_mode = {
                            a = { fg = "#141415", bg = "#f3be7c" },
                            b = { fg = "#f3be7c", bg = "#252530" },
                            c = { fg = "#cdcdcd", bg = "#141415" },
                        },
                        search_mode = {
                            a = { fg = "#141415", bg = "#6e94b2" },
                            b = { fg = "#6e94b2", bg = "#252530" },
                            c = { fg = "#cdcdcd", bg = "#141415" },
                        },
                        tab = {
                            active = { fg = "#cdcdcd", bg = "#252530" },
                            inactive = { fg = "#cdcdcd", bg = "#141415" },
                            inactive_hover = { fg = "#bb9dbd", bg = "#252530" },
                        },
                        scheme = {
                            foreground = "#cdcdcd",
                            background = "#141415",
                            cursor_fg = "#141415",
                            cursor_bg = "#cdcdcd",
                            cursor_border = "#cdcdcd",
                            ansi = {
                                "#252530",
                                "#d8647e",
                                "#7fa563",
                                "#f3be7c",
                                "#6e94b2",
                                "#bb9dbd",
                                "#aeaed1",
                                "#cdcdcd",
                            },
                            brights = {
                                "#606079",
                                "#e08398",
                                "#99b782",
                                "#f5cb96",
                                "#8ba9c1",
                                "#c9b1ca",
                                "#bebeda",
                                "#d7d7d7",
                            },
                        },
                    },
                    section_separators = {
                        left = "",
                        right = "",

                    },
                    component_separators = {
                        left = "",
                        right = "",
                    },
                    tab_separators = {
                        left = "",
                        right = "",
                    },
                },
                sections = {
                    tabline_a = "",
                    tabline_b = "",
                    tabline_x = "",
                    tabline_y = {
                        'datetime',
                        icons_enabled = false,
                        padding = { left = 5, right = 5 }

                    },
                    tabline_z = {
                        'domain',
                        icons_enabled = false,
                        padding = { left = 5, right = 5 }
                    },
                    tab_active = {
                        "index",
                        {
                            "process",
                            icons_enabled = false,
                            padding = { left = 0, right = 1 }
                        }
                    },
                    tab_inactive = {
                        'index',
                        {
                            'process',
                            icons_enabled = false,
                            padding = { left = 0, right = 1 }
                        }
                    },
                },

            })
          '';
        }).wrapper;
    };

  flake.wrapperModules.wezterm = inputs.wrappers.lib.wrapModule (
    {
      config,
      lib,
      # 1. Remove 'pkgs' from here!
      ...
    }:
    let
      toLua =
        val:
        if builtins.isBool val then
          (if val then "true" else "false")
        else if builtins.isFloat val || builtins.isInt val then
          builtins.toString val
        else if builtins.isString val then
          ''"${val}"''
        else
          throw "Unsupported type for toLua";

      pluginsLua = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          name: url: "local ${name} = wezterm.plugin.require('${url}')"
        ) config.settings.plugins
      );

      generatedLuaConfig = ''
        local wezterm = require 'wezterm'

        -- Load Plugins
        ${pluginsLua}

        local config = wezterm.config_builder()

        -- Auto-generated options from Nix
        config.font_size = ${toLua config.settings.fontSize}
        config.font = wezterm.font(${toLua config.settings.fontFamily}, { weight = ${toLua config.settings.fontWeight} })
        config.color_scheme = ${toLua config.settings.colorScheme}

        -- Custom raw Lua appended by the user
        ${config.extraConfig}

        return config
      '';

      # 2. Use config.pkgs here instead of just pkgs
      writeWeztermConfig = cfg: config.pkgs.writeText "wezterm.lua" cfg;
    in
    {
      options = {
        settings = {
          plugins = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
            description = "Wezterm plugins to require, mapping local variable names to plugin URLs.";
            example = {
              smart_splits = "https://github.com/mrjones2014/smart-splits.nvim";
            };
          };
          fontSize = lib.mkOption {
            type = lib.types.float;
            default = 12.0;
            description = "The font size to use in Wezterm.";
          };
          fontFamily = lib.mkOption {
            type = lib.types.str;
            default = "JetBrains Mono";
            description = "The font family to use in Wezterm.";
          };
          fontWeight = lib.mkOption {
            type = lib.types.str;
            default = "Bold";
            description = "The font weight to use in Wezterm.";
          };
          colorScheme = lib.mkOption {
            type = lib.types.str;
            default = "Raycast_Dark";
            description = "The color scheme for Wezterm.";
          };

          enableWayland = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable native Wayland support.";
          };
        };

        extraConfig = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = "Extra raw Lua configuration to append to wezterm.lua.";
        };
      };

      config = {
        # Wrap the writeWeztermConfig call in string interpolation
        env.WEZTERM_CONFIG_FILE = "${writeWeztermConfig generatedLuaConfig}";

        package = config.pkgs.wezterm;
      };
    }
  );
}
