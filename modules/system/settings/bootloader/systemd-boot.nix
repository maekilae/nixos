{
  flake.modules.nixos.systemdBoot = {
    boot.loader = {
      systemd-boot.enable = true;
    };
  };
}
