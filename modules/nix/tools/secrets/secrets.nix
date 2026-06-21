{
  inputs,
  ...
}:
let
  rekeySharedSettings =
    { config, lib, ... }:
    {
      age.rekey = {
        masterIdentities = [ ../../../../secrets/master.pub ];
        storageMode = "local";
        localStorageDir = lib.mkDefault (
          ../../../../secrets/rekeyed + "/${config.networking.hostName}"
        );
      };
    };
in
{
  flake.modules.nixos.secrets =
    { pkgs, ... }:
    {
      imports = [
        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
        rekeySharedSettings
      ];
      environment.systemPackages = [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.agenix-rekey.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

  flake.modules.darwin.secrets =
    { pkgs, ... }:
    {
      imports = [
        inputs.agenix.darwinModules.default
        inputs.agenix-rekey.darwinModules.default
        rekeySharedSettings
      ];
      environment.systemPackages = [
        inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.agenix-rekey.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

  flake.modules.homeManager.secrets =
    { ... }:
    {
      imports = [
        inputs.agenix.homeManagerModules.default
      ];
    };
}
