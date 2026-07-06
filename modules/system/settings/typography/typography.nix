{
  # Shared typography defaults. Read from perSystem packages (wezterm,
  # hyprqt6engine) *and* NixOS modules (gtk, ghostty) so all consumers agree
  # on family + size without each hardcoding "JetBrains Mono".
  #
  # Sizes are per-context, not per-family: `ui` is menubar/widget size,
  # `terminal` is what ghostty/wezterm want. Weights and per-consumer knobs
  # (e.g. wezterm's fontWeight) stay local — this is a defaults surface, not
  # a full typography system.
  config.flake.lib.fonts = {
    monospace.family = "JetBrains Mono";
    sans.family = "Inter";
    sizes = {
      ui = 11;
      terminal = 14;
    };
  };
}
