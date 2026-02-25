{
  flake.modules.nixos.zed =
    {
      pkgs,
      ...
    }:
    {
      programs.nix-ld.enable = true;
      environment.systemPackages = with pkgs; [
        zed-editor
        alejandra
        nil
        nixd
      ];

    };
}
