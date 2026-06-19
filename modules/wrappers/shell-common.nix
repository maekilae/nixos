{ lib, flake-parts-lib, ... }:
{
  options.flake = flake-parts-lib.mkSubmoduleOptions {
    shellCommon = lib.mkOption {
      type = lib.types.raw;
      description = ''
        Shared shell aliases/variables consumed by fish, zsh, and bash wrappers.
        A function of `{ pkgs, lib }` returning `{ aliases, variables }`.
      '';
    };
  };

  config.flake.shellCommon =
    { pkgs, lib }:
    {
      variables = {
        EDITOR = lib.getExe pkgs.neovim;
      };

      aliases = {
        ls = "${lib.getExe pkgs.eza} -l --icons";
        cat = lib.getExe' pkgs.bat "bat";
        cd = "z";
        nv = "${lib.getExe pkgs.neovim}";
        zz = "${lib.getExe pkgs.zed-editor} ./";
        rg = "${lib.getExe pkgs.ripgrep} --hidden";

        ll = "${lib.getExe pkgs.eza} -l --icons --git";
        la = "${lib.getExe pkgs.eza} -la --icons --git";
        lt = "${lib.getExe pkgs.eza} --tree --icons --git-ignore";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        g = "git";
        gs = "git status";
        gss = "git status -s";
        ga = "git add";
        gaa = "git add --all";
        gc = "git commit";
        gcm = "git commit -m";
        gca = "git commit --amend";
        gcan = "git commit --amend --no-edit";
        gco = "git checkout";
        gcb = "git checkout -b";
        gsw = "git switch";
        gswc = "git switch -c";
        gb = "git branch";
        gbd = "git branch -d";
        gp = "git push";
        gpf = "git push --force-with-lease";
        gpu = "git push -u origin HEAD";
        gpl = "git pull";
        gplr = "git pull --rebase";
        gf = "git fetch";
        gfa = "git fetch --all --prune";
        gl = "git log --oneline --graph --decorate";
        gla = "git log --oneline --graph --decorate --all";
        gd = "git diff";
        gds = "git diff --staged";
        gst = "git stash";
        gstp = "git stash pop";
        gsts = "git stash show -p";
        grh = "git reset --hard";
        grs = "git reset --soft";
        gm = "git merge";
        grb = "git rebase";
        grbi = "git rebase -i";
        gcl = "git clone";
        grst = "git restore";
        grsts = "git restore --staged";
      };
    };
}
