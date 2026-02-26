{ self, ... }:
{
  flake.modules.nixos.cli =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      environment.systemPackages = with pkgs; [
        selfpkgs.git
        bat
        eza
        vim
        ripgrep
        wget
        lazygit
        gh
        gh-notify
        zoxide
      ];
    };
}
