{
  config,
  lib,
  inputs,
  self,
  ...
}:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.fish =
        (self.wrapperModules.fish.apply {
          variables = {
            EDITOR = lib.getExe pkgs.neovim;
            FISH_GREETING = "";
          };
        }).wrapper;
    };
  flake.wrapperModules.fish = inputs.wrappers.lib.wrapModule (
    {
      config,
      lib,
      # 1. Remove 'pkgs' from here!
      ...
    }:
    let
      # Helper to serialize Nix types into Fish script variables/strings
      toFishStr =
        val:
        if builtins.isBool val then
          (if val then "1" else "0") # Fish treats non-zero/non-empty as truthy in custom ways, but standard bool logic applies
        else if builtins.isFloat val || builtins.isInt val then
          builtins.toString val
        else if builtins.isString val then
          # Escape single quotes for safe string interpolation in fish
          "'${lib.replaceStrings [ "'" ] [ "\\'" ] val}'"
        else
          throw "Unsupported type for toFishStr";

      # 1. Map aliases into `alias key=value` strings
      aliasesFish = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: "alias ${name}=${toFishStr value}") config.aliases
      );

      # 2. Map variables into `set -g key value` strings
      variablesFish = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: "set -g ${name} ${toFishStr value}") config.variables
      );

      # 3. Assemble the final config.fish script
      generatedFishConfig = ''
        # Auto-generated Nix configuration for Fish

        # Variables
        ${variablesFish}

        # Aliases
        ${aliasesFish}

        # Custom user-defined init script
        ${config.interactiveShellInit}
      '';

      # Write the derivation using config.pkgs
      writeFishConfig = cfg: config.pkgs.writeText "config.fish" cfg;

      # Evaluate the file path as a string (fixes the derivationStrict error)
      configFilePath = "${writeFishConfig generatedFishConfig}";
    in
    {
      options = {
        aliases = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "An attribute set mapping alias names to their commands.";
          example = {
            ll = "ls -l";
          };
        };

        variables = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.either lib.types.str (lib.types.either lib.types.bool lib.types.int)
          );
          default = { };
          description = "Global environment variables to set when fish starts.";
          example = {
            EDITOR = "nvim";
          };
        };

        interactiveShellInit = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = "Raw fish script text to run on startup.";
        };
      };

      config = {
        # We use the wrapper's 'flags' attribute to force fish to source our file on startup.
        # The --init-command flag evaluates the string as fish code.
        flags = {
          "--init-command" = "source ${configFilePath}";
        };
        package = config.pkgs.fish;
      };
    }
  );
}
