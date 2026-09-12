{
  flake.modules.nixos.orion =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.modules.browser.orion;
    in
    {
      options.modules.browser.orion = {
        enable = lib.mkEnableOption "Orion browser";
      };

      config = lib.mkIf cfg.enable {
        # Pulls in services.flatpak and registers Kagi's orion-beta remote;
        # Orion is Flatpak-only, so the browser itself still has to be fetched
        # once with `flatpak install orion-beta com.kagi.Orion`.
        anynix.program.orion.enable = true;
      };
    };
}
