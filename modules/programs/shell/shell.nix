{ self, ... }:
{
  flake.modules.nixos.shell =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      programs.zsh = {
        enable = true;
        # dotDir = "${config.xdg.configHome}/zsh";
        enableCompletion = true;
      };

      programs.bash = {
        enable = true;
        completion.enable = false;
      };

      environment.systemPackages = [
        selfpkgs.fish
      ];
    };
}
