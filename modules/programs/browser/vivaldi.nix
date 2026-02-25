{
  flake.modules.nixos.vivaldi =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.modules.browser.vivaldi;
    in
    {
      # Define the toggle
      options.modules.browser.vivaldi = {
        enable = lib.mkEnableOption "Vivaldi browser";
      };
      config = lib.mkIf cfg.enable {
        programs.vivaldi = {
          enable = true;
          extensions = [
            { id = "ghmbeldphafepmbegfdlkpapadhbakde"; }
            { id = "pncfbmialoiaghdehhbnbhkkgmjanfhe"; } # ublock list
            { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
          ];
        };
      };
    };
}
