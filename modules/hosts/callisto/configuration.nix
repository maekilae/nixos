{
  inputs,
  self,
  config,
  ...
}: {
  # Define the nixosConfiguration for this host
  flake.nixosConfigurations.callisto = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.callistoModule
    ];
  };
  flake.nixosModules.callistoModule = {pkgs, ...}: {
    imports = [
      /etc/nix/hardware-configuration.nix
    ];
    networking = {
      hostName = "callisto";
      networkmanager.enable = true;
    };
    boot = {
      loader.systemd-boot.enable = true;
    };
  };
}
