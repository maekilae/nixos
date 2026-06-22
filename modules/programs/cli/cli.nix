{ self, ... }:
let
  basePackages =
    pkgs: selfpkgs: with pkgs; [
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
      unzip
      claude-code
    ];
in
{
  flake.modules.nixos.cli =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      environment.systemPackages =
        basePackages pkgs selfpkgs
        ++ (with pkgs; [
          unrar-free
          usbutils
        ]);
    };

  flake.modules.darwin.cli =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      environment.systemPackages = basePackages pkgs selfpkgs;
    };
}
