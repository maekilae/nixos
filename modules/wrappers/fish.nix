{
  inputs,
  self,
  ...
}:
{
  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    {
      packages.fish =
        (self.wrapperModules.fish.apply {
          inherit pkgs;
          variables = {
            EDITOR = lib.getExe pkgs.neovim;
            fish_greeting = "";
          };
          aliases = {
            ls = "${lib.getExe pkgs.eza} -l --icons";
            cat = lib.getExe' pkgs.bat "bat"; # Remember the getExe trick!
            cd = "z";
            nv = "${lib.getExe pkgs.neovim}";
            zz = "${lib.getExe pkgs.zed-editor} ./";
            rg = "${lib.getExe pkgs.ripgrep} --hidden";
          };
          interactiveShellInit = # fish
            ''
              function fish_prompt --description 'Write out the prompt'
                      set -l last_status $status
                      set -l normal (set_color normal)
                      set -l status_color (set_color brgreen)
                      set -l cwd_color (set_color $fish_color_cwd)
                      set -l vcs_color (set_color brpurple)
                      set -l prompt_status ""

                      # Since we display the prompt on a new line allow the directory names to be longer.
                      set -q fish_prompt_pwd_dir_length
                      or set -lx fish_prompt_pwd_dir_length 0

                      # Color the prompt differently when we're root
                      set -l suffix '❯'
                      if functions -q fish_is_root_user; and fish_is_root_user
                              if set -q fish_color_cwd_root
                                      set cwd_color (set_color $fish_color_cwd_root)
                              end
                              set suffix '#'
                      end

                      # Color the prompt in red on error
                      if test $last_status -ne 0
                              set status_color (set_color $fish_color_error)
                              set prompt_status $status_color "[" $last_status "]" $normal
                      end

                      echo -s  $cwd_color (prompt_pwd) $vcs_color (fish_vcs_prompt) $normal ' ' $prompt_status
                      echo -n -s $status_color $suffix ' ' $normal
              end
              ${lib.getExe pkgs.zoxide} init fish | source
              direnv hook fish | source
            '';
        }).wrapper;
    };
  flake.wrapperModules.fish = inputs.wrappers.lib.wrapModule (
    {
      config,
      lib,
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
          "-C" = "source ${configFilePath}";
        };
        package = config.pkgs.fish;
      };
    }
  );
}
