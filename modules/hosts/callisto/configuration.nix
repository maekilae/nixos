{
  inputs,
  self,
  config,
  ...
}: {
  # Define the nixosConfiguration for this host
  flake.nixosConfigurations.callisto = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs self;
      vars = self.vars;
    };

    modules = [
      self.nixosModules.callistoModule
    ];
  };
  flake.nixosModules.callistoModule = {pkgs, ...}: {
    imports = [
      /etc/nix/hardware-configuration.nix
    ];
  };
}
