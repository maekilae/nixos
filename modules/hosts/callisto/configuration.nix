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
    ];
    networking = {
	hostName = "callisto";
	networkmanager.enable= true;
    };
    nixpkgs.config.allowUnfree = true;

    hardware = {
      enableAllFirmware = true;

      bluetooth.enable = true;
      bluetooth.powerOnBoot = true;

      graphics.enable = true;
      graphics.enable32Bit = true; # Replaced 'driSupport32Bit'    
    };
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    system.stateVersion = "26.05";
  };
}
