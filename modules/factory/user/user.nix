{
  self,
  inputs,
  ...
}:
{
  config.flake.factory.user = username: isAdmin: {

    nixos."${username}" =
      {
        lib,
        pkgs,
        ...
      }:
      {
        users.users."${username}" = {
          isNormalUser = true;
          home = "/home/${username}";
          extraGroups = lib.optionals isAdmin [
            "wheel"
          ];
          shell = pkgs.zsh;
          initialPassword = "12345";
        };
        programs.zsh.enable = true;

        # Home directory / dotfiles via Hjem (not Home Manager). The Hjem module
        # is imported once per system by mkNixos; here we just enable this user.
        hjem.users."${username}".enable = true;
      };

    darwin."${username}" =
      { lib, pkgs, ... }:
      {
        users.users."${username}" = {
          home = "/Users/${username}";
          shell = pkgs.zsh;
        };

        # Home directory / dotfiles via Hjem (not Home Manager). The Hjem module
        # itself is imported once per system by mkDarwin; here we just enable this
        # user. `directory` and `user` are derived from users.users."${username}".
        # Per-user files/packages/env go under `hjem.users."${username}"`.
        hjem.users."${username}".enable = true;

        system.primaryUser = lib.mkIf isAdmin "${username}";

        programs.zsh.enable = true;
      };
  };
}
