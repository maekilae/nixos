{ inputs, ... }:
{
  flake.modules.nixos.desktopEnv = {
    imports = with inputs.self.modules.nixos; [
      # cosmic
      # gnome
    ];
  };
}
