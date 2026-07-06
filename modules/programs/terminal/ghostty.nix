{
  inputs,
  ...
}:
let
  # "vague" — the dark palette already used by this repo's wezterm + neovim, so
  # Ghostty matches. (Swap `background`/`palette` for `theme = <name>` to use one
  # of Ghostty's built-in themes instead.)
  colors = ''
    background = 141415
    foreground = cdcdcd
    cursor-color = cdcdcd
    selection-background = 252530
    selection-foreground = cdcdcd
    palette = 0=#252530
    palette = 1=#d8647e
    palette = 2=#7fa563
    palette = 3=#f3be7c
    palette = 4=#6e94b2
    palette = 5=#bb9dbd
    palette = 6=#aeaed1
    palette = 7=#cdcdcd
    palette = 8=#606079
    palette = 9=#e08398
    palette = 10=#99b782
    palette = 11=#f5cb96
    palette = 12=#8ba9c1
    palette = 13=#c9b1ca
    palette = 14=#bebeda
    palette = 15=#d7d7d7
  '';

  # Shared config.fish-driven Ghostty config. `pkgs` is used to pin the exact
  # fish binary so Ghostty launches this repo's fish (which reads the Hjem-managed
  # ~/.config/fish/config.fish).
  mkConfig =
    { pkgs, lib }:
    ''
      # Managed by Nix via Hjem — do not edit by hand.

      # Shell: fish (reads ~/.config/fish/config.fish, also Hjem-managed).
      command = ${lib.getExe pkgs.fish} --login
      shell-integration = fish

      # Font
      font-family = JetBrains Mono
      font-size = 14

      # Cursor
      cursor-style = block
      cursor-style-blink = false
      mouse-hide-while-typing = true

      # Window
      window-padding-x = 12
      window-padding-y = 12
      window-padding-balance = true
      window-inherit-working-directory = true
      confirm-close-surface = false
      copy-on-select = clipboard

      # Colorscheme (vague — dark)
      ${colors}
    '';

  # macOS-only extras.
  darwinExtra = ''
    # macOS
    macos-option-as-alt = true
    macos-titlebar-style = tabs
    font-thicken = true
  '';
in
{
  # Ghostty terminal, installed + configured per-user via Hjem.
  #  - darwin: the Homebrew cask packaged by brew-nix (nix-brew), since GUI apps
  #    shouldn't be nixpkgs-built on macOS.
  #  - linux:  the nixpkgs build.
  # Hjem drops the package into every enabled user's profile (on darwin its .app
  # is linked into ~/Applications by Hjem's link-nix-apps agent) and writes
  # ~/.config/ghostty/config.
  flake.modules.darwin.ghostty =
    { pkgs, lib, ... }:
    {
      nixpkgs.overlays = [ inputs.brew-nix.overlays.default ];
      hjem.extraModules = [
        {
          packages = [ pkgs.brewCasks.ghostty ];
          files.".config/ghostty/config".text = mkConfig { inherit pkgs lib; } + darwinExtra;
        }
      ];
    };

  flake.modules.nixos.ghostty =
    { pkgs, lib, ... }:
    {
      hjem.extraModules = [
        {
          packages = [ pkgs.ghostty ];
          files.".config/ghostty/config".text = mkConfig { inherit pkgs lib; };
        }
      ];
    };
}
