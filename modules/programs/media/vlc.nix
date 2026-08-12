{
  flake.modules.nixos.vlc =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        vlc
      ];
    };
}
