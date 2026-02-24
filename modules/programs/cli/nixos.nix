{ self, ... }: {
  flake.modules.nixos.cli-tools = { pkgs, ... }: let
selfpkgs = self.packages."${pkgs.system}";
in
{
    environment.systemPackages = [
	selfpkgs.git
    ];
  };
}
