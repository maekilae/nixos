let
  port = 41641;
in {
  flake.nixosModules.tailscale = {pkgs, ...}: {
    environment.systemPackages = [
      pkgs.tailscale
    ];
    services.tailscale.enable = true;
    services.tailscale.port = port;
    networking.firewall.allowedUDPPorts = [port];
  };
}
