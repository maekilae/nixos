{
  inputs,
  ...
}:
{
  flake.modules.nixos.gnome = {

    imports = with inputs.self.modules.nixos; [
      gtk
    ];

    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    # programs.dconf.enable = true;

  };
}
