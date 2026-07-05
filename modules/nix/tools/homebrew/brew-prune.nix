{ inputs, ... }:
{
  # `nix run .#brew-prune` — uninstall Homebrew packages that this Nix config
  # already provides. The host's top-level package names (environment.systemPackages
  # + every Hjem user's packages) are computed HERE, at build time, and baked into
  # the command — so at runtime it needs only `brew`, no `nix`/daemon. `nix run`
  # re-evaluates the flake each invocation, so the baked list tracks your config.
  # Darwin-only.
  perSystem =
    { pkgs, lib, system, ... }:
    let
      # Lowercased package name for a systemPackages / home.packages entry.
      getName =
        p:
        if !(builtins.isAttrs p) then
          ""
        else if p ? pname then
          lib.toLower p.pname
        else
          lib.toLower (lib.getName p);

      namesFor =
        cfg:
        let
          sysPkgs = cfg.config.environment.systemPackages or [ ];
          hjemUsers = (cfg.config.hjem or { }).users or { };
          hjemPkgs = lib.concatMap (u: u.packages or [ ]) (lib.attrValues hjemUsers);
          raw = map getName (sysPkgs ++ hjemPkgs);
        in
        lib.naturalSort (lib.unique (builtins.filter (s: s != "") raw));

      # darwin hosts whose platform matches the system this package is built for.
      darwinCfgs = inputs.self.darwinConfigurations or { };
      hostsForSystem = lib.filterAttrs (
        _: cfg: (cfg.config.nixpkgs.hostPlatform.system or null) == system
      ) darwinCfgs;

      namesFile =
        host: cfg:
        pkgs.writeText "brew-prune-${host}.names" (lib.concatStringsSep "\n" (namesFor cfg) + "\n");

      mkCase = host: cfg: "${host}) cat '${namesFile host cfg}' ;;\n";

      # Bash preamble baking host -> name-list lookup into the command.
      preamble = ''
        __nix_names_for_host() {
          case "$1" in
            ${lib.concatStrings (lib.mapAttrsToList mkCase hostsForSystem)}*) return 1 ;;
          esac
        }
        __brew_prune_hosts() { printf '%s\n' ${lib.concatStringsSep " " (lib.attrNames hostsForSystem)}; }
      '';
    in
    {
      packages = lib.optionalAttrs pkgs.stdenv.isDarwin {
        brew-prune = pkgs.writeShellApplication {
          name = "brew-prune";
          runtimeInputs = with pkgs; [
            coreutils
            gnugrep
            gnused
          ];
          text = preamble + "\n" + builtins.readFile ./brew-prune.sh;
        };
      };
    };
}
