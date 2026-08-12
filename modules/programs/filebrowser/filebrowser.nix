{
  inputs,
  ...
}:
{
  flake.modules.nixos.filebrowser =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        kdePackages.qtsvg

        kdePackages.kio
        kdePackages.kio-fuse
        kdePackages.kio-extras

        kdePackages.dolphin

        kdePackages.ark

        kdePackages.okular

        # Thumbnail generators + extra image formats (heif/avif/jxl/…) so
        # Dolphin can preview PDFs, videos, and modern image formats.
        kdePackages.kdegraphics-thumbnailers
        kdePackages.ffmpegthumbs
        kdePackages.kimageformats

        rpi-imager
        rpiboot
      ];
      environment.etc."xdg/menus/applications.menu".source =
        "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

      # Network/MTP/trash/etc. mounts surfaced under `network:/` in Dolphin.
      services.gvfs.enable = true;

      # Phone <-> desktop bridge (file sharing, notifications, media control).
      programs.kdeconnect.enable = true;
    };
}
