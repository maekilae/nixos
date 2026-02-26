{
  inputs,
  ...
}:
{
  # expansion of cli system for desktop use

  flake.modules.nixos.system-desktop =
    { pkgs, self, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        # cli
        browser
        gnome
        gaming
        discord
        spotify
        terminal
        shell
        fonts
        dev
      ];
      modules.dev.enable = true;
      modules.dev.zed.enable = true;
      modules.browser.vivaldi.enable = false;
      # Set your time zone.
      time.timeZone = "Europe/Stockholm";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "sv_SE.UTF-8";
        LC_IDENTIFICATION = "sv_SE.UTF-8";
        LC_MEASUREMENT = "sv_SE.UTF-8";
        LC_MONETARY = "sv_SE.UTF-8";
        LC_NAME = "sv_SE.UTF-8";
        LC_NUMERIC = "sv_SE.UTF-8";
        LC_PAPER = "sv_SE.UTF-8";
        LC_TELEPHONE = "sv_SE.UTF-8";
        LC_TIME = "sv_SE.UTF-8";
      };

      services.upower.enable = true;
      security.polkit.enable = true;

    };

  flake.modules.darwin.system-desktop = {
    imports = with inputs.self.modules.darwin; [
    ];
  };

}
