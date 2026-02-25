{
  flake.modules.nixos.spotify =
    {
      pkgs,
      ...
    }:
    {
      programs.nix-ld.enable = true;
      environment.systemPackages = with pkgs; [
        spotify
      ];

    };
}
