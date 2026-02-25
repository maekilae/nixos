{
  flake.modules.nixos.vivaldi =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.modules.browser.vivaldi;
    in
    {
      # Define the toggle
      options.modules.browser.vivaldi = {
        enable = lib.mkEnableOption "Vivaldi browser";
        default = false;
      };
      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ pkgs.vivaldi ];

        # 2. Force-install extensions via the inherited Chromium policy path
        environment.etc."chromium/policies/managed/vivaldi_extensions.json".text = builtins.toJSON {
          ExtensionInstallForcelist = [
            "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx" # uBlock Origin
            "pncfbmialoiaghdehhbnbhkkgmjanfhe;https://clients2.google.com/service/update2/crx" # uBlock List
            "ghmbeldphafepmbegfdlkpapadhbakde;https://clients2.google.com/service/update2/crx" # Proton-pass
          ];
        };
      };
    };
}
