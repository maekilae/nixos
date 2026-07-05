{ self, ... }:
let
  # Common zsh + variables + shell wrapper packages.
  # Works on both nixos and nix-darwin.
  zshAndCommon =
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
        enableCompletion = true;
        interactiveShellInit = ''
          eval "$(${lib.getExe pkgs.zoxide} init zsh)"
          eval "$(direnv hook zsh)"
        '';
      };

      # `environment.shellAliases` works on both NixOS and nix-darwin, unlike
      # `programs.zsh.shellAliases` (NixOS-only).
      environment.shellAliases = common.aliases;
      environment.variables = common.variables;

      # fish is handled separately (see fish.nix): on both platforms its config is
      # written to ~/.config/fish/config.fish via Hjem with a plain programs.fish,
      # so no wrapped fish is installed here.
      environment.systemPackages = [
        selfpkgs.zsh
        selfpkgs.bash
      ];
    };
in
{
  flake.modules.nixos.shell =
    {
      pkgs,
      lib,
      ...
    }:
    let
      common = self.shellCommon { inherit pkgs lib; };
    in
    {
      imports = [ zshAndCommon ];

      programs.bash = {
        enable = true;
        completion.enable = false;
        shellAliases = common.aliases;
        interactiveShellInit = ''
          eval "$(${lib.getExe pkgs.zoxide} init bash)"
          eval "$(direnv hook bash)"
        '';
      };
    };

  flake.modules.darwin.shell = zshAndCommon;
}
