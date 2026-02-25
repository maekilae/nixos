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
        enableCompletion = true;
      };

      programs.bash = {
        enable = true;
        enableCompletion = true;
      };

      programs.fish = {
        enable = true;
        package = selfpkgs.fish;
      };

    };

}
