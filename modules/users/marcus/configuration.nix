{
  inputs,
  self,
  ...
}: let
  username = "marcus";
in {
  flake.modules.nixos."${username}" = {
    lib,
    config,
    pkgs,
    ...
  }: {
    imports = with inputs.self.modules.nixos; [
      hjem."${username}"
    ];

    users.users."${username}" = {
      isNormalUser = true;
      initialPassword = "pass";
      shell = pkgs.fish;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };
    programs.fish.enable = true;
  };
}
