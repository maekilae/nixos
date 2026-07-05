{
  inputs,
  lib,
  ...
}:
{
  # Helper functions for creating system configurations.
  # (No Home Manager: per-user home config is handled by Hjem, wired into each
  # system via factory.user — see modules/nix/tools/hjem.)

  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.lib = {
    mkNixos = system: name: {
      ${name} = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.self.modules.nixos.${name}
          # Hjem is imported here (once per system) rather than per-user or
          # per-fragment: its module is not safe to import multiple times.
          # factory.user / the fish fragment only set `hjem.*` options.
          inputs.self.modules.nixos.hjem
          {
            nixpkgs.hostPlatform = lib.mkDefault system;
          }
          inputs.anynix.default
        ];
      };
    };

    mkDarwin = system: name: {
      ${name} = inputs.nix-darwin.lib.darwinSystem {
        modules = [
          inputs.self.modules.darwin.${name}
          # Hjem is imported here (once per darwin system) rather than per-user or
          # per-fragment: its module is not safe to import multiple times.
          # factory.user / the fish fragment only set `hjem.*` options.
          inputs.self.modules.darwin.hjem
          {
            nixpkgs.hostPlatform = lib.mkDefault system;
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };
    };

  };
}
