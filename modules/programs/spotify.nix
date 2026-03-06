{inputs,...}:{
  flake.modules.nixos.spotify =
    {
      pkgs,
      ...
    }:
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      programs.spicetify = {
        enable = true;
        package = spicetify;
      };
      environment.systemPackages = with pkgs; [
        spicetify-cli
      ];

    };
}
