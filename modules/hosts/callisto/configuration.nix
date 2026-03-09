{
  inputs,
  ...
}:
{
  flake.modules.nixos.callisto = {
    imports = with inputs.self.modules.nixos; [
      system-desktop
      systemd-boot
      systemd-gc
      bluetooth
      firmware
    ];
    networking = {
      hostName = "callisto";
      networkmanager.enable = true;
    };
    nixpkgs.config.allowUnfree = true;

    modules.firmware.amd.enable = true;
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    system.stateVersion = "26.05";
  };
}
