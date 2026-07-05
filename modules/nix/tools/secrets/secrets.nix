{
  inputs,
  withSystem,
  ...
}:
let
  rekeySharedSettings =
    { config, lib, ... }:
    {
      age.rekey = {
        masterIdentities = [
          {
            identity = "/home/marcus/.config/agenix-rekey/master.age";
            pubkey = lib.fileContents ../../../../secrets/master.pub;
          }
        ];
        storageMode = "local";
        localStorageDir = lib.mkDefault (../../../../secrets + "/${config.networking.hostName}");
      };
    };
  agenixWrapperFor =
    system: withSystem system ({ config, ... }: config.agenix-rekey.package);
in
{
  perSystem = _: {
    # This repo has no Home Manager configs (home is managed by Hjem), so there
    # are no home-level secrets for agenix-rekey to rekey.
    agenix-rekey.homeConfigurations = { };
  };

  flake.modules.nixos.secrets =
    { pkgs, ... }:
    {
      imports = [
        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
        rekeySharedSettings
      ];
      environment.systemPackages = [
        (agenixWrapperFor pkgs.stdenv.hostPlatform.system)
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
        (agenixWrapperFor pkgs.stdenv.hostPlatform.system)
      ];
    };
}
