{ self, ... }:
{
  flake.modules.nixos.shell =
    {
      pkgs,
      lib,
      ...
    }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
      common = self.shellCommon { inherit pkgs lib; };
    in
    {
      programs.zsh = {
        enable = true;
        # dotDir = "${config.xdg.configHome}/zsh";
        enableCompletion = true;
        shellAliases = common.aliases;
        interactiveShellInit = ''
          eval "$(${lib.getExe pkgs.zoxide} init zsh)"
          eval "$(direnv hook zsh)"
        '';
      };

      programs.bash = {
        enable = true;
        completion.enable = false;
        shellAliases = common.aliases;
        interactiveShellInit = ''
          eval "$(${lib.getExe pkgs.zoxide} init bash)"
          eval "$(direnv hook bash)"
        '';
      };

      environment.variables = common.variables;

      environment.systemPackages = [
        selfpkgs.fish
        selfpkgs.zsh
        selfpkgs.bash
      ];
    };
}
