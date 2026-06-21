{
  inputs,
  ...
}:
{
  # age-encrypted secrets for NixOS / Darwin and Home Manager
  # https://github.com/ryantm/agenix
  # https://github.com/oddlama/agenix-rekey

  flake-file.inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "path:./secrets";
      flake = false;
    };
  };

  imports = [
    inputs.agenix-rekey.flakeModule
  ];
}
