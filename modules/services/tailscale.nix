{
  flake.modules.nixos.tailscale =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.modules.tailscale;
    in
    {
      options.modules.tailscale = {
        operator = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "marcus";
          description = ''
            User permitted to drive the daemon without root. Applied on
            activation as `tailscale set --operator=<user>`; without it the CLI
            and Trayscale refuse with "No permission to manage Tailscale".
          '';
        };

        tray.enable = lib.mkEnableOption "Trayscale, a tray GUI for the Tailscale daemon";
      };

      config = lib.mkMerge [
        {
          environment.systemPackages = with pkgs; [
            tailscale
          ];
          services.tailscale = {
            enable = true;
          };
        }

        (lib.mkIf (cfg.operator != null) {
          # Runs via the module's tailscaled-set unit, ordered after the daemon.
          services.tailscale.extraSetFlags = [ "--operator=${cfg.operator}" ];
        })

        (lib.mkIf cfg.tray.enable {
          environment.systemPackages = with pkgs; [
            trayscale
          ];

          systemd.user.services.trayscale = {
            description = "Trayscale tray icon for the Tailscale daemon";
            documentation = [ "https://github.com/DeedleFake/Trayscale" ];
            # graphical-session.target is reached in both sessions: uwsm raises
            # it for Hyprland, and cosmic-session.target binds to it under
            # COSMIC, so this follows whichever session the host logs into.
            wantedBy = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];
            after = [ "graphical-session.target" ];
            serviceConfig = {
              # Starts to the tray only; the window is opened from the icon.
              ExecStart = "${lib.getExe pkgs.trayscale} --hide-window";
              # The panel's status-area applet may not have claimed the
              # StatusNotifier bus name yet on a cold login.
              Restart = "on-failure";
              RestartSec = 5;
            };
          };
        })
      ];
    };
}
