{
  flake.modules.nixos.music =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.nix-ld.enable = true;
      environment.systemPackages = with pkgs; [
        spotify
      ];

    };
}
