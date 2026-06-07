{ inputs, ... }:
{
  flake.modules.nixos.compositor = {
    imports = with inputs.self.modules.nixos; [
      hyprland
    ];
  };
}
