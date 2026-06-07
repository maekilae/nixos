{ inputs, ... }:
{
  flake.modules.nixos.media = {
    imports = with inputs.self.modules.nixos; [
      cider
      spotify
    ];
  };
}
