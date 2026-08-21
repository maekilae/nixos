{ inputs, ... }:
{
  flake.modules.nixos.desktopEnv = {
    imports = with inputs.self.modules.nixos; [
      cosmic
      # gnome — not option-gated; importing it enables GDM + GNOME outright
    ];
  };
}
