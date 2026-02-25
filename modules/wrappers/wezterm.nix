{ inputs, util, ... }:
{
  flake.wrappers.wezterm =
    {
      config,
      pkgs,
      wlib,
      lib,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.wezterm ];
    };
}
