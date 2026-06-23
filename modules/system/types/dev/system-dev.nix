{
  inputs,
  ...
}:

{
  # Development workstation system type — currently darwin-only.
  # Geared toward a macOS dev box: shell, editor, and dev tooling,
  # no browsers, compositor, gaming, or other graphical applications
  # due to issues with nix on non nixOS systems.

  flake.modules.darwin.systemDev = {
    imports = with inputs.self.modules.darwin; [
      # system base
      secrets
      ssh
      shell
      # determinate   # enable once `determinate` is added to flake.nix inputs
      # homebrew      # enable once `brew-nix` is added to flake.nix inputs

      # dev program categories (no GUI)
      cli
      dev
      nvim
    ];

    time.timeZone = "Europe/Stockholm";

    modules.dev.enable = true;

    # macOS system defaults — minimal baseline; hosts can extend.
    system.defaults = {
      NSGlobalDomain.InitialKeyRepeat = 15;
      NSGlobalDomain.KeyRepeat = 2;
      finder.AppleShowAllExtensions = true;
      finder.FXEnableExtensionChangeWarning = false;
    };
  };
}
