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
      packages.hypridle =
        (self.wrapperModules.hypridle.apply {
          inherit pkgs;
          # package = lib.mkForce inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hypridle;

          general = {
            lock_cmd = "pidof hyprlock || ${lib.getExe pkgs.hyprlock}"; # avoid starting multiple hyprlock instances.
            before_sleep_cmd = "loginctl lock-session"; # loginctl is part of systemd
            after_sleep_cmd = "${lib.getExe pkgs.hyprland} dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
          };

          listeners = [
            {
              timeout = 150; # 2.5min.
              on-timeout = "${lib.getExe pkgs.brightnessctl} -s set 10"; # set monitor backlight to minimum
              on-resume = "${lib.getExe pkgs.brightnessctl} -r"; # monitor backlight restore.
            }
            # turn off keyboard backlight
            {
              timeout = 150;
              on-timeout = "${lib.getExe pkgs.brightnessctl} -sd rgb:kbd_backlight set 0";
              on-resume = "${lib.getExe pkgs.brightnessctl} -rd rgb:kbd_backlight";
            }
            {
              timeout = 300; # 5min
              on-timeout = "${lib.getExe pkgs.systemd} lock-session"; # loginctl
            }
            {
              timeout = 330; # 5.5min
              on-timeout = "${lib.getExe pkgs.hyprland} dispatch dpms off";
              on-resume = "${lib.getExe pkgs.hyprland} dispatch dpms on && ${lib.getExe pkgs.brightnessctl} -r";
            }
            {
              timeout = 1800; # 30min
              on-timeout = "systemctl suspend"; # suspend pc
            }
          ];
        }).wrapper;
    };

  flake.wrapperModules.hypridle = inputs.wrappers.lib.wrapModule (
    {
      config,
      lib,
      ...
    }:
    let
      # 1. Format the general block
      generalStr =
        if config.general != { } then
          ''
            general {
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: value: "    ${name} = ${builtins.toString value}") config.general
            )}
            }
          ''
        else
          "";

      # 2. Format the list of listeners
      listenersStr = lib.concatStringsSep "\n\n" (
        builtins.map (listener: ''
          listener {
          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (name: value: "    ${name} = ${builtins.toString value}") listener
          )}
          }
        '') config.listeners
      );

      # 3. Assemble the final hypridle.conf
      generatedHypridleConfig = ''
        # Auto-generated Nix configuration for Hypridle

        ${generalStr}

        ${listenersStr}
      '';

      # Write the derivation using config.pkgs
      writeHypridleConfig = cfg: config.pkgs.writeText "hypridle.conf" cfg;

      # Evaluate the file path as a string
      configFilePath = "${writeHypridleConfig generatedHypridleConfig}";
    in
    {
      options = {
        general = lib.mkOption {
          type = lib.types.attrsOf (lib.types.either lib.types.str lib.types.int);
          default = { };
          description = "General configuration options for hypridle.";
          example = {
            lock_cmd = "pidof hyprlock || hyprlock";
          };
        };

        listeners = lib.mkOption {
          type = lib.types.listOf (lib.types.attrsOf (lib.types.either lib.types.str lib.types.int));
          default = [ ];
          description = "A list of listener attribute sets.";
          example = [
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
          ];
        };
      };

      config = {
        # Force hypridle to use our generated config file.
        # Note: Depending on the specific wrapper implementation, you might pass "-c" or "--config"
        flags = {
          "-c" = "${configFilePath}";
        };
        package = config.pkgs.hypridle;
      };
    }
  );
}
