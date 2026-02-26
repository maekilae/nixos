{ inputs, self, ... }:
{
  flake.modules.nixos.gaming =
    {
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) mkDefault;
    in
    {
      hardware.graphics.enable = mkDefault true;

      nixpkgs.overlays = [ inputs.millennium.overlays.default ];

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
          package = pkgs.millennium-steam;
        };
      };

      environment.systemPackages = with pkgs; [
        steam-run
        dxvk
        gamescope
        mangohud
        heroic
        prismlauncher
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.wowup
      ];

    };
}
