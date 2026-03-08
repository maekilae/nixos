{ self, ... }:
{
  flake.modules.nixos.helium =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.modules.browser.helium;
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      # Define the toggle
      options.modules.browser.helium = {
        enable = lib.mkEnableOption "Helium browser";
        default = true;
      };
      config = lib.mkIf cfg.enable {
        environment.systemPackages = [ selfpkgs.helium-browser ];

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
