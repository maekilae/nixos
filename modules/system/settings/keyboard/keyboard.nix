{
  # US layout with the three Swedish vowels on AltGr: ; -> ö, ' -> ä, [ -> å
  # (shift for the capitals). Registering it here patches it into the system
  # xkb tree and exports XKB_CONFIG_ROOT, so libxkbcommon consumers - Hyprland,
  # cosmic-comp - resolve `se_extras` too, not just X11.
  flake.modules.nixos.keyboard = {
    services.xserver.xkb.extraLayouts.se_extras = {
      description = "English (US, Swedish letters)";
      languages = [
        "eng"
        "swe"
      ];
      symbolsFile = ./se-extras;
    };
  };
}
