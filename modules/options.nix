{ lib, pkgs, ... }:
{
  config = {

  };
  options = {
    system.defaultApps = {
      browser = lib.mkOption {
        type = lib.types.str;
        default = "firefox";
        description = "The default browser for the system.";
      };
    };
    system.shell = {
      default = lib.mkOption {
        type = lib.types.str;

        default = "/bin/bash";
        description = "The default shell for the system.";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.bash;
        description = "The default shell package for the system.";
      };
    };
    system.autoStart = lib.mkOption {
      type = lib.types.listOf (lib.types.str);
      default = [ ];
      description = "List of services to start automatically.";
    };
  };
}
