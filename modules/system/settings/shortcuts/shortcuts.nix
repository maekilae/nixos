{
  # Modifier-key convention per shortcut layer. Individual bindings stay in
  # each program (hyprland/wezterm/…) — their vocabulary differs too much to
  # share — but the modifier that groups them is centralized here so the
  # convention is documented and swappable.
  #
  # Layers:
  #   os          — compositor actions (spawn, kill, workspace switch, focus)
  #   terminal    — terminal-native bindings (copy/paste, tab open/close).
  #                 No consumer today; documented for future ghostty keybinds.
  #   multiplexer — wezterm LEADER (split/tab/pane). Press modifier+key, then
  #                 a follow-up key within timeoutMs.
  config.flake.lib.shortcuts = {
    os.modifier = "SUPER";

    terminal.modifier = "ctrl+shift";

    multiplexer = {
      modifier = "CTRL";
      key = "Space";
      timeoutMs = 2000;
    };
  };
}
