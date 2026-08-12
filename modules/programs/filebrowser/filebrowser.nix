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

        rpi-imager
        rpiboot
      ];
      environment.etc."xdg/menus/applications.menu".source =
        "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
    };
}
