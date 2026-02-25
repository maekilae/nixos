{
  flake.modules.nixos.dev =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.my.modules.dev;
    in
    {
      options.my.modules.dev = {
        enable = lib.mkEnableOption "the core development environment";
        zed.enable = lib.mkEnableOption "the Zed editor integration";
      };
      config = lib.mkIf cfg.enable (
        lib.mkMerge [

          # Base dev configuration (applied if my.modules.dev.enable = true)
          {
            programs.nix-ld.enable = true;
            environment.systemPackages = with pkgs; [
              alejandra
              nil
              nixd
            ];
          }

          # Zed-specific configuration (applied if my.modules.dev.zed.enable = true)
          (lib.mkIf cfg.zed.enable {

            environment.systemPackages = with pkgs; [
              zed-editor
            ];
          })
        ]
      );
    };
}
