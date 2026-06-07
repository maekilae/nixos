{
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos.ganymede =
    { config, ... }:
    {
      imports =
        with inputs.self.modules.nixos;
        with inputs.self.factory;
        [
          marcus
        ];
    };
}
