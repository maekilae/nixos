{
  inputs,
  ...
}:
{
  flake.modules.nixos.gnome = {

    imports = with inputs.self.modules.nixos; [
    ];

    services = {
      services.displayManager.cosmic-greeter.enable = true;
      services.desktopManager.cosmic.enable = true;
    };
  };
}
