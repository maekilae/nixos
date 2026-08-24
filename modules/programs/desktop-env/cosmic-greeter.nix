{ inputs, ... }:
{
  flake.modules.nixos.cosmicGreeter =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.modules.desktopEnv.cosmicGreeter;
    in
    {
      imports = with inputs.self.modules.nixos; [
        greeter
      ];

      options.modules.desktopEnv.cosmicGreeter = {
        enable = lib.mkEnableOption "the COSMIC greeter (greetd-based login manager)";

        priority = lib.mkOption {
          type = lib.types.int;
          default = 60;
          description = ''
            Priority in the greeter election. Defaults above SDDM (50), so
            enabling COSMIC hands it the login screen and drops every other
            session's greeter. Lower it below
            `modules.desktopEnv.hyprland.greeterPriority` to keep SDDM instead.
          '';
        };

        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.cosmic-greeter;
          defaultText = lib.literalExpression "pkgs.cosmic-greeter";
          description = "The cosmic-greeter package to run.";
        };

        cursorTheme = lib.mkOption {
          type = lib.types.str;
          default = "Bibata-Modern-Classic";
          description = "Cursor theme used on the greeter, matching the system cursor.";
        };
      };

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          modules.desktopEnv.greeters.cosmic-greeter = {
            enable = true;
            priority = cfg.priority;
          };
        })

        (lib.mkIf (config.modules.desktopEnv.activeGreeter == "cosmic-greeter") {
          services.displayManager.cosmic-greeter = {
            enable = true;
            package = cfg.package;
          };

          # The greeter reads XCURSOR_THEME from greetd's environment, falling
          # back to "Pop" when unset.
          environment.sessionVariables.XCURSOR_THEME = lib.mkDefault cfg.cursorTheme;
          environment.systemPackages = [ pkgs.bibata-cursors ];
        })
      ];
    };
}
