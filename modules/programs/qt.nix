{ inputs, ... }:
{
  flake.modules.nixos.gtk =
    { pkgs, ... }:
    let
      hyprqt6 = inputs.hyprqt6engine.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      environment.systemPackages = with pkgs; [
        hyprqt6
      ];
    };
}
