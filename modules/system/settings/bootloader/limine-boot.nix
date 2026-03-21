{
  flake.modules.nixos.limine-boot = {
    boot.loader = {
      limine.enable = true;
    };
  };
}
