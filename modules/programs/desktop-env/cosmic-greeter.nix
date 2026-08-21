{ ... }:
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
      options.modules.desktopEnv.cosmicGreeter = {
        enable = lib.mkEnableOption "COSMIC greeter (greetd-based login manager)";

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

      config = lib.mkIf cfg.enable {
        services.displayManager.cosmic-greeter = {
          enable = true;
          package = cfg.package;
        };

        # cosmic-greeter drives greetd, which cannot share a seat with SDDM —
        # the compositor fragment turns SDDM on, so take it back out here.
        services.displayManager.sddm.enable = lib.mkForce false;

        # The greeter reads XCURSOR_THEME from greetd's environment, falling
        # back to "Pop" when unset.
        environment.sessionVariables.XCURSOR_THEME = lib.mkDefault cfg.cursorTheme;
        environment.systemPackages = [ pkgs.bibata-cursors ];
      };
    };
}
