{
  inputs,
  self,
  lib,
  ...
}:
let
  fonts = self.lib.fonts;
  theme = self.lib.themes.vague;

  # Ghostty wants bare hex for background/foreground/selection-* and `#hex`
  # for palette entries. Strip the leading `#` for the former.
  bare = h: lib.removePrefix "#" h;

  paletteLines = lib.concatImapStringsSep "\n" (
    i: hex: "palette = ${toString (i - 1)}=${hex}"
  ) theme.palette;

  colors = ''
    background = ${bare theme.bg}
    foreground = ${bare theme.fg}
    cursor-color = ${bare theme.fg}
    selection-background = ${bare (builtins.elemAt theme.palette 0)}
    selection-foreground = ${bare theme.fg}
    ${paletteLines}
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
      font-family = ${fonts.monospace.family}
      font-size = ${toString fonts.sizes.terminal}

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

  # Linux-only extras. Ghostty's systemd/D-Bus activation keeps the process
  # warm so new windows open in ~20ms instead of ~300ms; the delay releases
  # memory if no window has been open for 5 minutes.
  # https://ghostty.org/docs/linux/systemd
  linuxExtra = ''
    # systemd/D-Bus activation
    quit-after-last-window-closed = true
    quit-after-last-window-closed-delay = 5m
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
          xdg.config.files."ghostty/config" = {
            text = mkConfig { inherit pkgs lib; } + darwinExtra;
            clobber = true; # Overwrites existing unmanaged file
          };
        }
      ];
    };

  flake.modules.nixos.ghostty =
    { pkgs, lib, ... }:
    {
      # Register ghostty's user unit + D-Bus service and enable it at login.
      systemd.packages = [ pkgs.ghostty ];
      systemd.user.services."app-com.mitchellh.ghostty".wantedBy = [ "default.target" ];

      hjem.extraModules = [
        {
          packages = [ pkgs.ghostty ];
          xdg.config.files."ghostty/config" = {
            text = mkConfig { inherit pkgs lib; } + linuxExtra;
            clobber = true; # Overwrites existing unmanaged file
          };
        }
      ];
    };
}
