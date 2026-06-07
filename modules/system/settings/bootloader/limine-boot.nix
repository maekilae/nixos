{
  flake.modules.nixos.limineBoot = {
    boot.loader = {
      limine.enable = true;
    };
  };
}
