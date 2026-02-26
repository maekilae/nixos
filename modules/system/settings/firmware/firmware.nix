{
  flake.modules.nixos.firmware =
    { config, lib, ... }:
    let
      cfg = config.modules.firmware;
    in
    {
      options.modules.firmware = {
        nvidia.enable = lib.mkEnableOption "NVIDIA GPU support";
        amd.enable = lib.mkEnableOption "AMD GPU support";
      };

      config = lib.mkMerge [
        # Global config that always applies when this module is loaded
        {
          services.fwupd.enable = true;
          hardware.enableAllFirmware = true;
          hardware.enableRedistributableFirmware = true;
          nixpkgs.config.allowUnfree = true;
        }

        # Conditional config for AMD
        (lib.mkIf cfg.amd.enable {
          hardware.graphics.enable = true;
          hardware.graphics.enable32Bit = true;
        })

        # You can add the NVIDIA logic here later
        (lib.mkIf cfg.nvidia.enable {
          # hardware.nvidia...
        })
      ];
    };
}
