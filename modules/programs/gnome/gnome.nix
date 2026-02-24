{
  inputs,
  pkgs,
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

  #flake.modules.homeManager.gnome = {
  #  dconf.settings = {
  #    "org/gnome/desktop/interface" = {
  #      enable-hot-corners = true;
  #    };
  #    "org/nemo/preferences" = {
  #      confirm-move-to-trash = true;
  #    };
  #  };
  #};
}
