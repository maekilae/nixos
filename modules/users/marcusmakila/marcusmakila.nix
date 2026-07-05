{
  self,
  lib,
  ...
}:
{
  # macOS account on `europa`. Distinct from the NixOS `marcus` user because the
  # login name on the Mac is `marcusmakila` (home /Users/marcusmakila) — nix-darwin
  # manages a real account, so the fragment name must match the OS account.
  flake.modules = lib.mkMerge [
    (self.factory.user "marcusmakila" true)
    {
      darwin.marcusmakila = {
        imports = with self.modules.darwin; [
        ];

        # Per-user home config is managed by Hjem (factory.user enables it).
        # Add files / packages / env here, e.g.:
        #   hjem.users.marcusmakila.files.".config/foo".text = "hello";
        #   hjem.users.marcusmakila.environment.sessionVariables.EDITOR = "nvim";
        # For packages, take `{ pkgs, ... }:` above and set:
        #   hjem.users.marcusmakila.packages = with pkgs; [ ripgrep fd ];
      };
    }
  ];
}
