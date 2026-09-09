{
  self,
  inputs,
  ...
}:
{
  # Hyprland as a full session: compositor + caelestia (its quickshell-based
  # shell) + hypridle/hyprlock, with SDDM registered as its greeter. The shell
  # is not optional here — a bare compositor with no panel, launcher or lock
  # screen is not a session anyone logs into.
  flake.modules.nixos.hyprland =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.modules.desktopEnv.hyprland;

      silent-sddm = pkgs.stdenv.mkDerivation {
        name = "silent-sddm";

        src = pkgs.fetchFromGitHub {
          owner = "uiriansan";
          repo = "SilentSDDM";
          rev = "v1.4.2";
          sha256 = "WeoJBj/PhqFCCJEIycTipqPbKm5BpQT2uzFTYcYZ30I=";
        };

        propagatedUserEnvPkgs = with pkgs.kdePackages; [
          qtsvg
          qtmultimedia
          qtvirtualkeyboard
          qtdeclarative
        ];

        installPhase = ''
          mkdir -p $out/share/sddm/themes/silent
          cp -r * $out/share/sddm/themes/silent/
        '';
      };
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      imports = with inputs.self.modules.nixos; [
        gtk
        greeter
      ];

      options.modules.desktopEnv.hyprland = {
        enable = lib.mkEnableOption "the Hyprland session (compositor + caelestia shell)";

        greeterPriority = lib.mkOption {
          type = lib.types.int;
          default = 50;
          description = ''
            Priority of SDDM in the greeter election. Raise another session's
            priority above this to hand the login screen to that session.
          '';
        };
      };

      config = lib.mkMerge [
        (lib.mkIf cfg.enable {
          environment.systemPackages = with pkgs; [
            bibata-cursors
            silent-sddm
            # The shell that makes this a session rather than a bare compositor.
            selfpkgs.caelestia
          ];
          environment.sessionVariables.NIXOS_OZONE_WL = "1";
          programs.uwsm.enable = true;

          modules.desktopEnv.greeters.sddm = {
            enable = true;
            priority = cfg.greeterPriority;
          };

          systemd.user.services.hypridle = {
            enable = true;
            description = "Hyprland's idle daemon";
            wantedBy = [ "hyprland-session.target" ];
            partOf = [ "graphical-session.target" ];
            serviceConfig = {
              ExecStart = lib.mkForce [
                ""
                "${selfpkgs.hypridle}/bin/hypridle"
              ];
              Restart = "always";
            };
          };
          programs.hyprlock = {
            enable = true;
            package = inputs.hyprlock.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;
          };

          programs.hyprland = {
            enable = true;
            package = selfpkgs.hyprland;
            withUWSM = true;
            xwayland.enable = true;
            portalPackage =
              inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
          };
        })

        (lib.mkIf (config.modules.desktopEnv.activeGreeter == "sddm") {
          services.displayManager.sddm = {
            enable = true;
            wayland = {
              enable = true;
              compositor = "kwin"; # Does not work without this
            };
            theme = "silent";
            package = pkgs.kdePackages.sddm;
            extraPackages = with pkgs; [
              silent-sddm
              kdePackages.qtsvg
              kdePackages.qtmultimedia
              kdePackages.qtvirtualkeyboard
            ];
          };
        })
      ];
    };
}
