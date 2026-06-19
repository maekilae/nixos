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
      packages.bash =
        let
          common = self.shellCommon { inherit pkgs lib; };
        in
        (self.wrapperModules.bash.apply {
          inherit pkgs;
          inherit (common) variables aliases;
          interactiveShellInit = # bash
            ''
              # History
              HISTFILE="$HOME/.bash_history"
              HISTSIZE=10000
              HISTFILESIZE=10000
              HISTCONTROL=ignoreboth:erasedups
              shopt -s histappend
              shopt -s checkwinsize
              shopt -s globstar 2>/dev/null
              shopt -s autocd 2>/dev/null

              # Prompt: cwd in cyan, git branch in magenta, red [status] on error
              __bash_git_branch() {
                git symbolic-ref --short HEAD 2>/dev/null \
                  || git rev-parse --short HEAD 2>/dev/null
              }
              __bash_prompt() {
                local status=$?
                local cyan='\[\e[36m\]' magenta='\[\e[35m\]' red='\[\e[31m\]'
                local green='\[\e[32m\]' reset='\[\e[0m\]'
                local branch; branch=$(__bash_git_branch)
                local vcs=""; [ -n "$branch" ] && vcs=" ''${magenta}(''${branch})''${reset}"
                local err=""; [ $status -ne 0 ] && err="''${red}[''${status}] "
                PS1="''${cyan}\w''${reset}''${vcs}\n''${err}''${green}❯''${reset} "
              }
              PROMPT_COMMAND=__bash_prompt

              # zoxide
              eval "$(${lib.getExe pkgs.zoxide} init bash)"
              # direnv
              eval "$(direnv hook bash)"
            '';
        }).wrapper;
    };

  flake.wrapperModules.bash = inputs.wrappers.lib.wrapModule (
    {
      config,
      lib,
      ...
    }:
    let
      toBashStr =
        val:
        if builtins.isBool val then
          (if val then "1" else "0")
        else if builtins.isFloat val || builtins.isInt val then
          builtins.toString val
        else if builtins.isString val then
          "'${lib.replaceStrings [ "'" ] [ "'\\''" ] val}'"
        else
          throw "Unsupported type for toBashStr";

      aliasesBash = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: "alias ${name}=${toBashStr value}") config.aliases
      );

      variablesBash = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: "export ${name}=${toBashStr value}") config.variables
      );

      generatedBashrc = ''
        # Auto-generated Nix configuration for Bash

        # Only run interactive setup when interactive
        case $- in *i*) ;; *) return ;; esac

        # Variables
        ${variablesBash}

        # Aliases
        ${aliasesBash}

        # Custom user-defined init script
        ${config.interactiveShellInit}
      '';

      configFilePath = "${config.pkgs.writeText "bashrc" generatedBashrc}";
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
          description = "Global environment variables to set when bash starts.";
          example = {
            EDITOR = "nvim";
          };
        };

        interactiveShellInit = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = "Raw bash script text to run on startup.";
        };
      };

      config = {
        flags = {
          "--rcfile" = configFilePath;
        };
        package = config.pkgs.bashInteractive;
      };
    }
  );
}
