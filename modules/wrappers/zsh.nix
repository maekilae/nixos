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
      packages.zsh =
        let
          common = self.shellCommon { inherit pkgs lib; };
        in
        (self.wrapperModules.zsh.apply {
          inherit pkgs;
          inherit (common) variables aliases;
          interactiveShellInit = # bash
            ''
              # History
              HISTFILE="$HOME/.zsh_history"
              HISTSIZE=10000
              SAVEHIST=10000
              setopt HIST_IGNORE_ALL_DUPS
              setopt HIST_IGNORE_SPACE
              setopt SHARE_HISTORY
              setopt INC_APPEND_HISTORY

              # Sensible defaults
              setopt AUTO_CD
              setopt EXTENDED_GLOB
              setopt INTERACTIVE_COMMENTS

              # Completion
              autoload -Uz compinit && compinit
              zstyle ':completion:*' menu select
              zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

              # Prompt: cwd + git branch on one line, status indicator on next
              autoload -Uz vcs_info
              setopt PROMPT_SUBST
              zstyle ':vcs_info:git:*' formats ' %F{magenta}(%b)%f'
              zstyle ':vcs_info:*' enable git
              precmd() { vcs_info }
              PROMPT='%F{cyan}%~%f''${vcs_info_msg_0_}
              %(?.%F{green}.%F{red}[%?] )❯%f '

              # zoxide
              eval "$(${lib.getExe pkgs.zoxide} init zsh)"
              # direnv
              eval "$(direnv hook zsh)"
            '';
        }).wrapper;
    };

  flake.wrapperModules.zsh = inputs.wrappers.lib.wrapModule (
    {
      config,
      lib,
      ...
    }:
    let
      # Single-quote-safe serializer for zsh. Inside '...' the only way to embed
      # a literal ' is to close, escape, and reopen: '\''.
      toZshStr =
        val:
        if builtins.isBool val then
          (if val then "1" else "0")
        else if builtins.isFloat val || builtins.isInt val then
          builtins.toString val
        else if builtins.isString val then
          "'${lib.replaceStrings [ "'" ] [ "'\\''" ] val}'"
        else
          throw "Unsupported type for toZshStr";

      aliasesZsh = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: "alias ${name}=${toZshStr value}") config.aliases
      );

      variablesZsh = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: "export ${name}=${toZshStr value}") config.variables
      );

      generatedZshrc = ''
        # Auto-generated Nix configuration for Zsh

        # Variables
        ${variablesZsh}

        # Aliases
        ${aliasesZsh}

        # Custom user-defined init script
        ${config.interactiveShellInit}
      '';

      # zsh has no "source this file" CLI flag like fish's -C. Instead, point
      # ZDOTDIR at a directory containing our generated .zshrc.
      zshConfigDir = config.pkgs.runCommand "zsh-config" { } ''
        mkdir -p $out
        cp ${config.pkgs.writeText "zshrc" generatedZshrc} $out/.zshrc
      '';
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
          description = "Global environment variables to set when zsh starts.";
          example = {
            EDITOR = "nvim";
          };
        };

        interactiveShellInit = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = "Raw zsh script text to run on startup.";
        };
      };

      config = {
        env.ZDOTDIR = "${zshConfigDir}";
        package = config.pkgs.zsh;
      };
    }
  );
}
