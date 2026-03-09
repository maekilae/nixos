{ inputs, ... }:
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
      imports = [ inputs.anynix.helium ];
      options.modules.browser.helium = {
        enable = lib.mkEnableOption "Helium browser";
        default = true;
      };
      config = lib.mkIf cfg.enable {
        programs.helium = {
          enable = true;
          enableWidevine = true;
          extensions = [
            "ghmbeldphafepmbegfdlkpapadhbakde" # Proton-pass
            "jplgfhpmjnbigmhklmmbgecoobifkmpa" # Proton-VPN
          ];
        };
      };
    };
}
