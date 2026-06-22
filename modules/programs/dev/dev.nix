{ inputs, ... }:
let
  devOptions =
    lib:
    {
      enable = lib.mkEnableOption "the core development environment";
      zed.enable = lib.mkEnableOption "the Zed editor integration";
    };

  baseDev = pkgs: {
    environment.systemPackages = with pkgs; [
      alejandra
      nil
      nixd
      go
    ];
    programs.direnv.enable = true;
  };

  zedDev = pkgs: {
    environment.systemPackages = with pkgs; [ zed-editor ];
  };
in
{
  flake.modules.nixos.dev =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.modules.dev;
    in
    {
      imports = with inputs.self.modules.nixos; [ cli ];
      options.modules.dev = devOptions lib;
      config = lib.mkIf cfg.enable (lib.mkMerge [
        (baseDev pkgs)
        { programs.nix-ld.enable = true; } # Linux-only
        (lib.mkIf cfg.zed.enable (zedDev pkgs))
      ]);
    };

  flake.modules.darwin.dev =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.modules.dev;
    in
    {
      imports = with inputs.self.modules.darwin; [ cli ];
      options.modules.dev = devOptions lib;
      config = lib.mkIf cfg.enable (lib.mkMerge [
        (baseDev pkgs)
        (lib.mkIf cfg.zed.enable (zedDev pkgs))
      ]);
    };
}
