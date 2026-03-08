{ self, inputs, ... }:
{
  flake.modules.nixos.gtk =
    { pkgs, ... }:
    let
      hyprqt6engine = inputs.hyprqt6engine.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      environment.systemPackages = [
        # hyprqt6engine
        (self.wrapperModules.hyprqt6engine.apply {
          inherit pkgs;
          # Example usage of your new options
          color_scheme = "";
          icon_theme = "Flat-Remix-Blue-Light";
          style = "kvantum-dark";
          font_fixed = "JetBrains Mono";
          font_fixed_size = 11;
          font = "Inter";
          font_size = 11;
        }).wrapper
      ];
      qt = {
        enable = true;
      };
      # xdg.configFile = {
      #   "hypr/hyprqt6engine.conf".text = ''
      #     color_scheme = ""
      #     icon_theme = "Flat-Remix-Blue-Light"
      #     style = "Fusion"
      #     font_fixed = "JetBrains Mono"
      #     font_fixed_size = "11"
      #     font = "Inter"
      #     font_size = "11"
      #   '';

      # };
    };

}
