{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wrappers.url = "github:Lassulus/wrappers";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";

    #impermanence.url = "github:nix-community/impermanence";
    import-tree.url = "github:vic/import-tree";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    packages = {
      flake = false;
      url = "path:./packages";
    };

    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    secrets = {
      flake = false;
      url = "path:./secrets";
    };
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprland.url = "github:hyprwm/Hyprland"; # Dev version
    hyprwm.url = "github:hyprwm/hyprnix";
    hypridle.url = "github:hyprwm/hypridle"; # TEMP
    #Previously swww
    awww.url = "git+https://codeberg.org/LGFae/awww";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

}
