{
  self,
  lib,
  ...
}:
{
  flake.modules = lib.mkMerge [
    (self.factory.user "marcus" true)
    {
      nixos.marcus = {
        imports = with self.modules.nixos; [
        ];
        users.users.marcus = {
          extraGroups = [
            "wheel"
            "networkmanager"
            "kvm"
            "video"
            "audio"
          ];
        };
      };

      darwin.marcus = {
        imports = with self.modules.darwin; [
          # drawingApps
          # developmentEnvironment
        ];
      };

    }
  ];
}
