{
  flake.modules.nixos.fonts =
    {
      pkgs,
      ...
    }:
    {
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

    };
}
