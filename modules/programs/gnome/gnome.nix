{
  ...
}:
{
  flake.modules.nixos.gnome = {

    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    programs.dconf.enable = true;

  };
}
