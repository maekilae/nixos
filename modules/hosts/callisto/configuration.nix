{
  inputs,
  ...
}:
{
  flake.modules.nixos.callisto = {
    imports = with inputs.self.modules.nixos; [
      system-desktop
      systemd-boot
      bluetooth
      firmware
    ];
    networking = {
      hostName = "callisto";
      networkmanager.enable = true;
    };
    nixpkgs.config.allowUnfree = true;

    modules.firmware.amd.enable = true;
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    system.stateVersion = "26.05";
  };
}
