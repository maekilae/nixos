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
      };

      homeManager.marcusmakila = {
        home.stateVersion = "26.05";
        # home-manager follows `nixpkgs` (unstable) while the darwin system uses
        # `nixpkgs-darwin`; the version mismatch is benign here, so silence the check.
        home.enableNixpkgsReleaseCheck = false;
      };
    }
  ];
}
