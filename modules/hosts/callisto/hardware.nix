{
  flake.modules.nixos.callisto = {
  modulesPath, ...}:{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e185a1c7-1016-4675-a02f-efc822595a7e";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/EB4C-1F47";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/3797c350-6276-4382-8d31-665519774594"; }
    ];

 fileSystems."/media/games" = {
   device = "/dev/disk/by-uuid/af7663d8-afd6-4480-a201-839c654166f9";
   fsType = "ext4";
   options = [ # If you don't have this options attribute, it'll default to "defaults" 
     "users" # Allows any user to mount and unmount
     "nofail" # Prevent system from failing if this drive doesn't mount
     "exec"
   ];
 };


    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = true;
  };
}


