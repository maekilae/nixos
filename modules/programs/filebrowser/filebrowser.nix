{
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
      ];
    };
}
