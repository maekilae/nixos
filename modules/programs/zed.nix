{
  flake.modules.nixos.zed = {
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) mkDefault;
  in {
    programs.nix-ld.enable = true;
    environment.systemPackages = with pkgs; [
      zed-editor
      alejandra
      nil
    ];

  };
}
