{
  inputs,
  lib,
  ...
}:
{
  flake.modules.nixos.callisto = {
    imports = with inputs.self.modules.nixos; [
      systemDesktop
      systemdBoot
      systemdGc
      bluetooth
      firmware
      secrets
    ];
    networking = {
      hostName = "callisto";
      networkmanager.enable = true;
    };

    age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHu9khzqPFNK3V18UlVYeM3sq1LNINcMYQA/7IP/2Cms root@callisto";
    nixpkgs.config.allowUnfree = lib.mkForce true;

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
        # Using systemd gc
        automatic = false;
      };
    };

    # Refer to docs before changing
    system.stateVersion = "26.05";
  };
}
