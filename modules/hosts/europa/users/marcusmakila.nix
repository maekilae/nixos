{
  inputs,
  ...
}:
{
  flake.modules.darwin.europa = {
    imports = with inputs.self.modules.darwin; [
      marcusmakila
    ];
  };
}
