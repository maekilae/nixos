{ lib, ... }:
{
  flake.modules.nixos.gtk =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        flat-remix-icon-theme
        adw-gtk3
        gnome-themes-extra
        # Provides gsettings + schemas so non-GNOME apps can resolve theme settings.
        glib
        gsettings-desktop-schemas
      ];

      programs.dconf.enable = true;
      programs.dconf.profiles.user.databases = [
        {
          settings."org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-theme = "adw-gtk3-dark";
            icon-theme = "Flat-Remix-Blue-Light";

            cursor-theme = "Bibata-Modern-Classic";
            cursor-size = lib.gvariant.mkInt32 24;

            font-name = "Inter 11";
            document-font-name = "Inter 11";
            monospace-font-name = "JetBrains Mono 11";
          };
        }
      ];

      # Non-GNOME GTK3 apps don't read dconf; they read this ini.
      environment.etc."xdg/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=adw-gtk3-dark
        gtk-icon-theme-name=Flat-Remix-Blue-Light
        gtk-cursor-theme-name=Bibata-Modern-Classic
        gtk-cursor-theme-size=24
        gtk-font-name=Inter 11
        gtk-application-prefer-dark-theme=true
      '';

      # GTK4 / libadwaita ignores gtk-theme-name for widget styling but still
      # reads icon/cursor/font from here.
      environment.etc."xdg/gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=adw-gtk3-dark
        gtk-icon-theme-name=Flat-Remix-Blue-Light
        gtk-cursor-theme-name=Bibata-Modern-Classic
        gtk-cursor-theme-size=24
        gtk-font-name=Inter 11
        gtk-application-prefer-dark-theme=true
      '';

      environment.sessionVariables = {
        GTK_THEME = "adw-gtk3-dark";
        XCURSOR_THEME = "Bibata-Modern-Classic";
        XCURSOR_SIZE = "24";
      };
    };
}
