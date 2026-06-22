{ inputs, self, ... }:
{
  flake.modules.nixos.gaming =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib) mkDefault;

      # The caelestia (Quickshell) launcher starts apps via `app2unit`, which
      # wraps them in a transient systemd scope (`app.slice`, `--collect`).
      # Steam re-execs itself on startup, the scope is then garbage-collected,
      # and the whole Steam process tree dies before the window ever appears -
      # so Steam only launches from a terminal, never from the launcher.
      #
      # Re-dispatching through the compositor makes Hyprland spawn Steam as one
      # of its own children (exactly like a terminal launch), which survives.
      # Generated from the packaged entry so it tracks upstream Exec lines.
      steamLauncherEntry = pkgs.runCommand "steam-hyprland.desktop" { } ''
        sed 's|^Exec=steam|Exec=hyprctl dispatch exec steam|' \
          ${config.programs.steam.package}/share/applications/steam.desktop > "$out"
      '';
    in
    {
      imports = [ inputs.hjem.nixosModules.default ];

      # User-level XDG override (wins over the programs.steam system entry).
      hjem.users.marcus.files.".local/share/applications/steam.desktop" = {
        source = steamLauncherEntry;
        clobber = true;
      };

      hardware.graphics.enable = mkDefault true;

      # Upstream's `millennium-typescript-bun-deps` pins a stale `outputHash`;
      # `bun install` produces a different hash and the fixed-output derivation
      # fails. The bad hash lives in a let-binding inside millennium.nix, so it
      # can't be reached via `overrideAttrs` - patch the file at eval time and
      # callPackage the patched copy. Drop once upstream bumps the hash.
      nixpkgs.overlays = [
        inputs.millennium.overlays.default
        (
          final: prev:
          let
            millenniumPkgDir = inputs.millennium.outPath;
            patchedMillennium = builtins.toFile "millennium.nix" (
              builtins.replaceStrings
                [ "sha256-XMYpHMrcmLNQYyLkc3DngjsZ4DdyPr9on0v5lcDrRiY=" ]
                [ "sha256-KDzbqRN1aobT5wMJI+P03i5hMzWCZv51mxRSpbVm4KI=" ]
                (builtins.readFile (millenniumPkgDir + "/millennium.nix"))
            );
            millennium = prev.callPackage patchedMillennium {
              inputs = {
                luajit-src = inputs.millennium.inputs.luajit-src;
              };
              millennium-src = inputs.millennium.inputs.millennium-src;
            };
          in
          {
            millennium-steam = prev.callPackage (millenniumPkgDir + "/steam.nix") {
              inherit millennium;
            };
          }
        )
      ];

      programs = {
        gamemode.enable = true;
        gamescope.enable = true;
        steam = {
          enable = true;
          extraCompatPackages = with pkgs; [
            proton-ge-bin
          ];
          extraPackages = with pkgs; [
            SDL2
            gamescope
          ];
          protontricks.enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
          # package = pkgs.millennium-steam;
        };
      };

      environment.systemPackages = with pkgs; [
        steam-run
        dxvk
        gamescope
        mangohud
        heroic
        prismlauncher
        inputs.anynix.packages.${pkgs.stdenv.hostPlatform.system}.wowup
        azahar
        melonds
        ckan
      ];

    };
}
