{
  inputs,
  ...
}:
{
  flake.modules.nixos.gnome = {

    imports = with inputs.self.modules.nixos; [
    ];

    services = {
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic.enable = true;
    };
  };
}
