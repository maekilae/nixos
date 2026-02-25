{
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos.callisto =
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
