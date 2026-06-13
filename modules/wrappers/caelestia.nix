{
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      # The caelestia CLI bundled with the shell. Exposes the `caelestia`
      # binary (so `caelestia shell -d` works from compositor startup and
      # keybinds) and propagates `caelestia-shell` onto PATH as well.
      packages.caelestia =
        inputs.caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.with-shell;
    };
}
