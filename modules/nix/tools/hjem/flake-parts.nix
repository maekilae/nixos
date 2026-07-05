{
  # Declarative home/dotfile management (this repo's Home Manager replacement).
  # https://github.com/feel-co/hjem
  flake-file.inputs = {
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
