{
  # NetBird's nixpkgs module is considerably richer than tailscale's: it already
  # builds the netbird-ui wrapper (services.netbird.ui.enable, which defaults on
  # wherever a graphical session exists) and can restrict daemon control to a
  # system group. So this only mirrors the two knobs modules.tailscale adds by
  # hand - a user granted control, and autostart for the tray.
  flake.modules.nixos.netbird =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.modules.netbird;
      # `services.netbird.enable` is shorthand for this one client.
      client = config.services.netbird.clients.default;
    in
    {
      options.modules.netbird = {
        operator = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "marcus";
          description = ''
            User permitted to manage the daemon without root. Unlike tailscale
            there is no operator flag: control is granted by group, and the
            group only guards the socket when the client is `hardened`, so
            setting this switches hardening on and adds the user to the
            client's group.
          '';
        };

        tray.enable = lib.mkEnableOption "the netbird-ui tray applet";
      };

      config = lib.mkMerge [
        { services.netbird.enable = true; }

        (lib.mkIf (cfg.operator != null) {
          services.netbird.clients.default.hardened = true;
          users.users.${cfg.operator}.extraGroups = [ client.user.group ];
        })

        (lib.mkIf cfg.tray.enable {
          systemd.user.services.netbird-ui = {
            description = "NetBird tray applet";
            # Same target as trayscale: uwsm raises it for Hyprland and
            # cosmic-session.target binds to it under COSMIC.
            wantedBy = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];
            after = [ "graphical-session.target" ];
            serviceConfig = {
              # The module's wrapper, not the bare package - it carries the
              # NB_STATE_DIR/socket environment this client was configured with.
              ExecStart = "${client.wrapper}/bin/netbird-ui";
              # Carried over from the packaged .desktop entry; the wails webkit
              # view renders blank under Wayland with the dmabuf renderer.
              Environment = [ "WEBKIT_DISABLE_DMABUF_RENDERER=1" ];
              Restart = "on-failure";
              RestartSec = 5;
            };
          };
        })
      ];
    };
}
