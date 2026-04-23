{
  inputs,
  ...
}:
{
  flake.modules.nixos.filebrowser =
    { pkgs, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        qt
      ];
      environment.systemPackages = with pkgs; [
        kdePackages.qtsvg

        kdePackages.kio
        kdePackages.kio-fuse
        kdePackages.kio-extras

        kdePackages.dolphin

        kdePackages.ark
      ];
      environment.etc."xdg/menus/applications.menu".source =
        "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
    };
}
