{
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      # The caelestia shell, exposed the same way as `quickshell` so it can be
      # started from a compositor via `getExe self.packages.${system}.caelestia`.
      # `default` is the shell; use `with-cli` instead if you want the
      # `caelestia` CLI bundled alongside it.
      packages.caelestia =
        inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
}
