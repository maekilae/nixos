{ self, ... }:
{
  flake.modules.nixos.shell =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.system}";
    in
    {
      programs.zsh = {
        enable = true;
        # dotDir = "${config.xdg.configHome}/zsh";
        enableCompletion = false;
      };

      programs.bash = {
        enable = true;
        completion.enable = false;
      };

      # programs.fish = {
      #   enable = true;
      #   package = selfpkgs.fish;
      # };

      environment.systemPackages = [
        selfpkgs.fish
      ];

    };

}
