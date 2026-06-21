{
  inputs,
  lib,
  ...
}:
{
  flake.modules.nixos.ganymede = {
    imports = with inputs.self.modules.nixos; [
      systemdBoot
      systemdGc
      bluetooth
      firmware
      secrets
    ];
    networking = {
      hostName = "ganymede";
      networkmanager.enable = true;
    };
    nixpkgs.config.allowUnfree = lib.mkForce true;

    # TODO: replace with the contents of /etc/ssh/ssh_host_ed25519_key.pub on this host
    age.rekey.hostPubkey = "ssh-ed25519 AAAA_REPLACE_ME_GANYMEDE";

    # modules.firmware.amd.enable = true;
    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # substituters = [ "https://hyprland.cachix.org" ];
        # trusted-substituters = [ "https://hyprland.cachix.org" ];
        # trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      };
      gc = {
        # Using systemd gc
        automatic = false;
      };
    };

    # Refer to docs before changing
    system.stateVersion = "25.11";
  };
}
