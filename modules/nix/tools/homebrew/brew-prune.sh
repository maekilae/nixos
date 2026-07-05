# brew-prune — uninstall Homebrew packages that this Nix config already provides.
#
# Name-matches installed Homebrew formulae and casks (case-insensitive, exact)
# against the top-level packages the host's nix-darwin + Home Manager config
# installs, and removes the Homebrew copies. The Nix-provided names are baked in
# at build time (see brew-prune.nix), so this needs only `brew` at runtime — no
# `nix`, no daemon. Dry-run by default; pass --yes to actually uninstall.
#
# The `__nix_names_for_host` / `__brew_prune_hosts` helpers and the bash shebang
# + `set -euo pipefail` are prepended by brew-prune.nix / writeShellApplication.

# Make sure Homebrew is reachable even if we inherited a slimmed-down PATH.
export PATH="${PATH}:/opt/homebrew/bin:/usr/local/bin"

host="$(hostname -s 2>/dev/null || hostname || true)"
assume_yes=0
do_formulae=1
do_casks=1

usage() {
  cat <<'USAGE'
brew-prune — uninstall Homebrew packages that your Nix config already provides.

It name-matches installed Homebrew formulae and casks (case-insensitive, exact)
against the top-level packages your nix-darwin + Home Manager config installs,
then removes the Homebrew copies. Dry-run by default.

Usage:
  brew-prune [options]

Options:
  -y, --yes            Actually uninstall (default is a dry run / preview).
      --host NAME      Host whose Nix package list to use (default: hostname -s).
      --formulae-only  Only consider Homebrew formulae.
      --casks-only     Only consider Homebrew casks.
  -h, --help           Show this help.

  nix run .#brew-prune              # preview what would be removed
  nix run .#brew-prune -- --yes     # actually uninstall
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -y|--yes) assume_yes=1; shift ;;
    --host) host="${2:?--host needs a value}"; shift 2 ;;
    --formulae-only) do_casks=0; shift ;;
    --casks-only) do_formulae=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "brew-prune: unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if ! command -v brew >/dev/null 2>&1; then
  echo "brew-prune: 'brew' not found on PATH" >&2
  exit 1
fi

if [ -z "$host" ]; then
  echo "brew-prune: could not determine hostname; pass --host NAME" >&2
  exit 1
fi

# Nix-provided package names for this host, baked in at build time.
if ! nix_names_raw="$(__nix_names_for_host "$host")"; then
  echo "brew-prune: no Nix package list baked in for host '${host}'." >&2
  echo "  hosts built into this command: $(__brew_prune_hosts | tr '\n' ' ')" >&2
  echo "  pass --host NAME, or rebuild brew-prune on the target machine." >&2
  exit 1
fi

nix_names="$(printf '%s\n' "$nix_names_raw" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -e 's/[[:space:]]*$//' -e '/^$/d' \
  | sort -u)"

if [ -z "$nix_names" ]; then
  echo "brew-prune: Nix config for '${host}' installs no packages to match against." >&2
  exit 0
fi

# Currently-installed Homebrew packages, normalized for matching.
brew_formulae=""
brew_casks=""
if [ "$do_formulae" -eq 1 ]; then
  brew_formulae="$(brew list --formula -1 2>/dev/null | tr '[:upper:]' '[:lower:]' | sed '/^$/d' | sort -u || true)"
fi
if [ "$do_casks" -eq 1 ]; then
  brew_casks="$(brew list --cask -1 2>/dev/null | tr '[:upper:]' '[:lower:]' | sed '/^$/d' | sort -u || true)"
fi

matched_formulae=""
matched_casks=""
if [ -n "$brew_formulae" ]; then
  matched_formulae="$(comm -12 <(printf '%s\n' "$brew_formulae") <(printf '%s\n' "$nix_names"))"
fi
if [ -n "$brew_casks" ]; then
  matched_casks="$(comm -12 <(printf '%s\n' "$brew_casks") <(printf '%s\n' "$nix_names"))"
fi

count() { if [ -n "$1" ]; then printf '%s\n' "$1" | grep -c . ; else echo 0; fi; }
n_f="$(count "$matched_formulae")"
n_c="$(count "$matched_casks")"

echo
echo "Homebrew packages also provided by Nix (host '${host}'):"
if [ "$n_f" -gt 0 ]; then
  echo "  formulae (${n_f}):"
  printf '%s\n' "$matched_formulae" | sed 's/^/    - /'
fi
if [ "$n_c" -gt 0 ]; then
  echo "  casks (${n_c}):"
  printf '%s\n' "$matched_casks" | sed 's/^/    - /'
fi
if [ "$n_f" -eq 0 ] && [ "$n_c" -eq 0 ]; then
  echo "  (none — nothing to uninstall)"
  exit 0
fi

if [ "$assume_yes" -ne 1 ]; then
  echo
  echo "Dry run — nothing was uninstalled. Re-run with --yes to apply."
  exit 0
fi

uninstall_each() {
  kind="$1"
  list="$2"
  [ -n "$list" ] || return 0
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    if [ "$kind" = cask ]; then
      if brew uninstall --cask "$name"; then
        echo "  removed cask: $name"
      else
        echo "  kept cask:    $name (uninstall failed — left in place)" >&2
      fi
    else
      if brew uninstall --formula "$name"; then
        echo "  removed formula: $name"
      else
        echo "  kept formula:    $name (other Homebrew packages may depend on it)" >&2
      fi
    fi
  done <<EOF
$list
EOF
}

echo
echo "==> Uninstalling..."
if [ "$do_formulae" -eq 1 ]; then uninstall_each formula "$matched_formulae"; fi
if [ "$do_casks" -eq 1 ]; then uninstall_each cask "$matched_casks"; fi

echo
echo "Done. Run 'brew autoremove' to clean up now-orphaned dependencies if you like."
