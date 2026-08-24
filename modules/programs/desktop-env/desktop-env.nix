{ inputs, ... }:
{
  # Sessions a host can log into. These are peers — Hyprland ships a compositor
  # plus the caelestia shell, COSMIC ships its own — and more than one may be
  # enabled at once; they land as separate entries on the login screen. Which
  # login manager runs is decided by the `greeter` election, not by import order.
  flake.modules.nixos.desktopEnv = {
    imports = with inputs.self.modules.nixos; [
      greeter
      hyprland
      cosmic
      # gnome — not option-gated; importing it enables GDM + GNOME outright
    ];
  };
}
