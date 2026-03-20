{ ... }:
{
  flake.modules.nixos.helium =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.modules.browser.helium;
    in
    {
      options.modules.browser.helium = {
        enable = lib.mkEnableOption "Helium browser";
        default = true;
      };
      config = lib.mkIf cfg.enable {
        anynix.program.helium = {
          enable = true;
          enableWidevine = true;
        };
      };
    };
}
