{
  flake.modules.nixos.firmware =
    { config, lib, pkgs, ... }:
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

          # Load amdgpu in initrd so KMS takes over before the boot splash —
          # cleaner boot and no mode switch flash on RDNA cards.
          boot.initrd.kernelModules = [ "amdgpu" ];

          # RDNA4 (RX 9070 series, Navi 48) needs a recent kernel. Unstable's
          # default is usually fine; pin to latest to be safe.
          boot.kernelPackages = pkgs.linuxPackages_latest;

          # VA-API + Vulkan userspace. mesa provides RADV by default; add the
          # VA driver bits explicitly so VLC/mpv/browsers get HW decode.
          hardware.graphics.extraPackages = with pkgs; [
            libva
            libva-utils
            libva-vdpau-driver
            libvdpau-va-gl
          ];
        })

        # You can add the NVIDIA logic here later
        (lib.mkIf cfg.nvidia.enable {
          # hardware.nvidia...
        })
      ];
    };
}
