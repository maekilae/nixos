{ ... }:
{
  # Arbiter for login managers. A session fragment does not enable its greeter
  # directly — it registers the greeter here with a priority, and this module
  # elects exactly one winner. That way two sessions can be installed side by
  # side (pick either one at the login screen) without their greeters fighting
  # over the seat.
  flake.modules.nixos.greeter = {
    # Every session fragment that registers a greeter imports this one, so it
    # is pulled in several times per host. The explicit key lets the module
    # system dedupe those imports instead of reporting the options below as
    # declared twice.
    key = "dendritic:desktop-env/greeter";
    imports = [
      (
        { config, lib, ... }:
        let
          greeters = config.modules.desktopEnv.greeters;
          # builtins.sort is stable and attrNames comes out sorted, so equal
          # priorities break on name and the winner stays deterministic.
          elected = lib.sort (a: b: greeters.${a}.priority > greeters.${b}.priority) (
            lib.attrNames (lib.filterAttrs (_: g: g.enable) greeters)
          );
        in
        {
          options.modules.desktopEnv = {
            greeters = lib.mkOption {
              default = { };
              description = ''
                Login managers requested by the enabled sessions. Only the
                highest-priority entry is actually configured; see `activeGreeter`.
              '';
              type = lib.types.attrsOf (
                lib.types.submodule (
                  { name, ... }:
                  {
                    options = {
                      enable = lib.mkEnableOption "${name} as a candidate login manager";

                      priority = lib.mkOption {
                        type = lib.types.int;
                        default = 50;
                        description = ''
                          Highest priority among the enabled greeters wins the seat.
                          Ties break on greeter name.
                        '';
                      };
                    };
                  }
                )
              );
            };

            activeGreeter = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              description = ''
                The greeter that won the election, or null when no session
                registered one. Each greeter gates its own config on this. Set it
                with `lib.mkForce` to override the election by hand.
              '';
            };
          };

          config.modules.desktopEnv.activeGreeter = if elected == [ ] then null else lib.head elected;
        }
      )
    ];
  };
}
