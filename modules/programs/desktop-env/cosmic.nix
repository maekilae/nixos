{ inputs, ... }:
{
  flake.modules.nixos.cosmic =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.modules.desktopEnv.cosmic;
    in
    {
      imports = with inputs.self.modules.nixos; [
        gtk
        cosmicGreeter
      ];

      options.modules.desktopEnv.cosmic = {
        enable = lib.mkEnableOption "COSMIC desktop environment";

        xwayland.enable = lib.mkEnableOption "Xwayland support for cosmic-comp" // {
          default = true;
        };

        excludePackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          example = lib.literalExpression "[ pkgs.cosmic-player ]";
          description = "COSMIC packages to leave out of the system closure.";
        };

        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = with pkgs; [ cosmic-ext-tweaks ];
          description = "Extra packages installed alongside the COSMIC session.";
        };
      };

      config = lib.mkIf cfg.enable {
        services.desktopManager.cosmic = {
          enable = true;
          xwayland.enable = cfg.xwayland.enable;
        };

        environment.cosmic.excludePackages = cfg.excludePackages;
        environment.systemPackages = cfg.extraPackages;

        # COSMIC ships its own greeter; a host can opt out and pick another one.
        modules.desktopEnv.cosmicGreeter.enable = lib.mkDefault true;

        environment.sessionVariables.NIXOS_OZONE_WL = "1";
      };
    };
}
