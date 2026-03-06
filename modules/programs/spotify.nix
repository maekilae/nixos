{ inputs, ... }:
{
  flake.modules.nixos.spotify =
    {
      pkgs,
      ...
    }:
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [
        inputs.spicetify-nix.nixosModules.spicetify
      ];
      programs.spicetify = {
        enable = true;
        # theme = spicePkgs.themes.dribbblish;
        theme = {
          name = "Dribbblish";
          src = spicePkgs.themes.dribbblish.src;
          requiredExtensions = [
            {
              src = spicePkgs.themes.dribbblish.src;
              name = "theme.js";
            }
          ];
          patches = {
            "xpui.js_find_8008" = ",(\\w+=)32";
            "xpui.js_repl_8008" = ",\${1}56";
          };
          overwriteAssets = true;

          additionalCss = ''
            .Root {
              padding-top: 0px;
            }
          '';
        };
        colorScheme = "dark";

      };
      environment.systemPackages = with pkgs; [
        spicetify-cli
      ];

    };
}
