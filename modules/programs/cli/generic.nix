let
  genericPackages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        bat
        eza
        vim
        lazygit
        gh
        gh-notify
        zoxide
      ];
    };
in
{
  flake.modules.nixos.cli-tools = {
    imports = [
      genericPackages
    ];
  };

  flake.modules.darwin.cli-tools = {
    imports = [
      genericPackages
    ];
  };
}
