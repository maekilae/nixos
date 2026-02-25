{
  inputs,
  ...
}:
{
  # expansion of cli system for desktop use

  flake.modules.nixos.system-desktop =
    { pkgs, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        cli-tools
        browser
        gnome
        gaming
        discord
        zed
        spotify
        terminal
        shell
        fonts
      ];
      fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
          # Provides Helvetica and Mac-like metrics alternatives
          liberation_ttf
          helvetica-neue-lt-std

          # Modern UI & Web Fonts
          inter
          roboto
          open-sans
          lato
          ubuntu-classic
          cantarell-fonts

          # Internationalization & Emojis
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji

          # Nerd Fonts
          nerd-fonts.fira-code
          nerd-fonts.droid-sans-mono
          nerd-fonts.jetbrains-mono

          ubuntu-sans
          cm_unicode
          corefonts
          unifont
        ];

        fontconfig.defaultFonts = {
          sansSerif = [
            "Inter"
            "Roboto"
            "Arial"
            "Noto Sans"
          ];
          serif = [
            "Georgia"
            "Times New Roman"
            "Noto Serif"
          ];
          monospace = [
            "JetBrains Mono"
            "Fira Code"
            "Courier New"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };

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
