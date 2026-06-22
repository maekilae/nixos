{
  inputs,
  self,
  ...
}:

{
  # expansion of cli system for desktop use

  flake.modules.nixos.systemDesktop =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      imports = with inputs.self.modules.nixos; [
        # system base
        shell
        tailscale
        cli

        # desktop program categories
        theming
        media
        compositor
        browser
        terminal
        gaming
        discord
        dev
        filebrowser
        cad
        editor
      ];

      time.timeZone = "Europe/Stockholm";

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

      modules.dev.enable = true;
      modules.dev.zed.enable = true;
      modules.browser.vivaldi.enable = false;
      modules.browser.helium.enable = true;

      xdg.portal = {
        enable = true;
        extraPortals = [
          pkgs.kdePackages.xdg-desktop-portal-kde
        ];
      };

      environment.systemPackages = with pkgs; [
        inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
        inputs.anynix.packages.${pkgs.stdenv.hostPlatform.system}.affinity
        qalculate-qt
        pavucontrol
      ];

      programs.niri.enable = false;
      programs.niri.package = selfpkgs.niri;
    };

  flake.modules.darwin.systemDesktop = {
    imports = with inputs.self.modules.darwin; [
    ];
  };

}
