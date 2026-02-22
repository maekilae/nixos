{inputs, ...}: let
  username = "marcus";
in {
  flake.nixosModules.hjem."${username}" = {pkgs, ...}: {
    imports = [
      inputs.hjem.nixosModules.default
    ];

    config = {
      hjem = {
        users."${username}" = {
          enable = true;
          directory = "/home/${username}";
          user = "${username}";
        };

        # clobberByDefault = true;
      };
    };
  };
}
