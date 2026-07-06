{
  # Shared color palette(s). Consumed by ghostty + wezterm (tabline). Neovim
  # and wezterm's main terminal colors come from the vague-nvim / vague-wezterm
  # plugins — those live in external repos, so changing hexes here doesn't
  # follow them; keep this in sync with the plugins if you ever fork the theme.
  #
  # Convention: palette[7] == fg and palette[0] is used as a "chrome" surface
  # (selection bg, inactive-tab bg). Standard 16-color ANSI layout,
  # 0-7 normal, 8-15 bright.
  config.flake.lib.themes.vague = {
    bg = "#141415";
    fg = "#cdcdcd";
    palette = [
      "#252530" # 0  black
      "#d8647e" # 1  red
      "#7fa563" # 2  green
      "#f3be7c" # 3  yellow
      "#6e94b2" # 4  blue
      "#bb9dbd" # 5  magenta
      "#aeaed1" # 6  cyan
      "#cdcdcd" # 7  white  (== fg)
      "#606079" # 8  bright black
      "#e08398" # 9  bright red
      "#99b782" # 10 bright green
      "#f5cb96" # 11 bright yellow
      "#8ba9c1" # 12 bright blue
      "#c9b1ca" # 13 bright magenta
      "#bebeda" # 14 bright cyan
      "#d7d7d7" # 15 bright white
    ];
  };
}
