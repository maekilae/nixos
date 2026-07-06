{
  self,
  ...
}:
let
  # config.fish generated from the shared shell-common aliases/variables, plus a
  # prompt and tool init. Written to ~/.config/fish/config.fish via Hjem (below)
  # rather than baked into a wrapped fish package — so it is portable and works on
  # nix-darwin with a plain `programs.fish`, no Nix-built wrapper needed.
  mkConfigFish =
    { pkgs, lib }:
    let
      common = self.shellCommon { inherit pkgs lib; };
      esc = lib.replaceStrings [ "'" ] [ "\\'" ];
      aliasLines = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (n: v: "alias ${n}='${esc v}'") common.aliases
      );
      varLines = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (n: v: "set -gx ${n} '${esc (toString v)}'") common.variables
      );
    in
    ''
      # Managed by Nix via Hjem — do not edit by hand.
      set -g fish_greeting ""

      # Environment variables (shell-common)
      ${varLines}

      # Aliases (shell-common)
      ${aliasLines}

      # Prompt: cwd + git on one line, status indicator on the next
      function fish_prompt --description 'Write out the prompt'
          set -l last_status $status
          set -l normal (set_color normal)
          set -l status_color (set_color brgreen)
          set -l cwd_color (set_color $fish_color_cwd)
          set -l vcs_color (set_color brpurple)
          set -l prompt_status ""

          set -q fish_prompt_pwd_dir_length
          or set -lx fish_prompt_pwd_dir_length 0

          set -l suffix '❯'
          if functions -q fish_is_root_user; and fish_is_root_user
              if set -q fish_color_cwd_root
                  set cwd_color (set_color $fish_color_cwd_root)
              end
              set suffix '#'
          end

          if test $last_status -ne 0
              set status_color (set_color $fish_color_error)
              set prompt_status $status_color "[" $last_status "]" $normal
          end

          echo -s $cwd_color (prompt_pwd) $vcs_color (fish_vcs_prompt) $normal ' ' $prompt_status
          echo -n -s $status_color $suffix ' ' $normal
      end

      # Tools
      ${lib.getExe pkgs.zoxide} init fish | source
      direnv hook fish | source
    '';

  # Shared body: enable fish, and drop the generated config.fish into every
  # Hjem user's home (~/.config/fish/config.fish).
  fishBody =
    { pkgs, lib, ... }:
    {
      programs.fish.enable = true;
      hjem.extraModules = [
        { xdg.config.files."fish/config.fish".text = mkConfigFish { inherit pkgs lib; }; }
      ];
    };
in
{
  # Hjem is imported once per system by mkNixos / mkDarwin, so these fragments
  # only carry the fish body (enable fish + write config.fish via Hjem).
  flake.modules.darwin.fish.imports = [ fishBody ];
  flake.modules.nixos.fish.imports = [ fishBody ];
}
