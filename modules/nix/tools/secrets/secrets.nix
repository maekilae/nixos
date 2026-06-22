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
    # No active home-manager configurations yet — skip the dormant mkHome placeholder
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

  flake.modules.homeManager.secrets =
    { ... }:
    {
      imports = [
        inputs.agenix.homeManagerModules.default
      ];
    };
}
