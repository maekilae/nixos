{ ... }:
{
  flake.modules.nixos.gtk =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.flat-remix-icon-theme
      ];
      programs.dconf.enable = true;
      programs.dconf.profiles.user.databases = [
        {
          settings."org/gnome/desktop/interface" = {
            gtk-theme = "Adwaita-dark";
            icon-theme = "Flat-Remix-Blue-Light";

            font-name = "Inter 11";
            document-font-name = "Inter 11";
            monospace-font-name = "JetBrains Mono 11";
          };

          # Optional: Set the Titlebar font to match
          # settings."org/gnome/desktop/wm/preferences" = {
          #   titlebar-font = "Inter Bold 11";
          # };
        }
      ];
    };
}
