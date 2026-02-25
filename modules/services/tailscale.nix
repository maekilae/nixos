{
  flake.modules.nixos.tailscale =
    {
      pkgs,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        tailscale
        tailscale-systray
      ];

    };
}
