# CLAUDE.md

NixOS + nix-darwin configuration built on the **dendritic pattern**: every `.nix`
file under `modules/` is a [flake-parts](https://github.com/hercules-ci/flake-parts)
module, auto-imported by [import-tree](https://github.com/vic/import-tree). There
are no manual import lists in `flake.nix` — adding a file *is* wiring it in.

## Architecture

### The dendritic pattern

- `flake.nix` wires the inputs and the body `inputs.import-tree ./modules`, so every
  `.nix` file in `modules/` is loaded as a flake-parts module. [flake-file](https://github.com/vic/flake-file)
  *can* generate it from `flake-file.inputs` declarations, **but the repo is only
  partially migrated**: most inputs live directly in `flake.nix` and are *not* declared
  in any module. Running `nix run .#write-flake` today regenerates `flake.nix` from the
  module declarations alone and **drops every hand-maintained input** — so don't run it.
  Add new inputs directly to the `inputs = { … }` block in `flake.nix` (see
  [Adding things](#adding-things)).
- Each module is a function `{ inputs, lib, self, config, ... }: { ... }`. Instead
  of producing a host config directly, modules contribute **named, reusable module
  fragments** to the flake:
  - `flake.modules.nixos.<name>` — a NixOS module
  - `flake.modules.darwin.<name>` — a nix-darwin module
  - `flake.modules.generic.<name>` — module usable across classes
  - `perSystem.packages.<name>` — a package (wrappers, custom builds)

  There is **no Home Manager** — per-user home/dotfile config is done with **Hjem**
  (see [Home directories](#home-directories-hjem)), configured *inside* the nixos/darwin
  fragments via `hjem.users.<user>`, not as a separate module class.
- **Fragments merge by name.** Several files may each define
  `flake.modules.nixos.callisto`; the module system merges them. This is why hosts
  are split into `configuration.nix`, `users/*.nix`, etc. — all targeting the same
  name.
- **Reference fragments by name**, never by path:
  ```nix
  imports = with inputs.self.modules.nixos; [ cli dev browser ];
  ```
  `self` and `inputs.self` are equivalent here; both are used in the tree.

### Factory (parametric fragments)

`flake.factory.<name>` holds **functions** that return module fragments, for things
that must be instantiated per-argument (a user, a mount, …). See
[modules/factory/](modules/factory).

```nix
# definition — modules/factory/user/user.nix
config.flake.factory.user = username: isAdmin: { nixos.${username} = …; darwin.${username} = …; };

# use — modules/users/marcus/marcus.nix
flake.modules = lib.mkMerge [ (self.factory.user "marcus" true) { … } ];
```

### Host assembly helpers

`flake.lib.{mkNixos,mkDarwin}` (in [modules/nix/flake-parts/lib.nix](modules/nix/flake-parts/lib.nix))
turn a named module fragment into a real system. A host's `flake-parts.nix` calls
them:

```nix
flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "callisto";
```

### Composition layers (how a host is built)

```
host (callisto)            ── imports ──▶ system type (systemDesktop)
  └ modules/hosts/<host>/                   └ imports ──▶ program categories (cli, browser, dev, …)
                                            └ imports ──▶ system settings (bluetooth, bootloader, …)
  └ users/<user>.nix       ── imports ──▶ user fragment (marcus) ── via factory.user
```

## Layout

```
modules/
  nix/
    flake-parts/        Dendritic plumbing: lib (mkNixos/…), factory + wrapper +
                        darwin + shellCommon option declarations, dendritic-tools setup.
    tools/<tool>/       One dir per nix tool (secrets, pkgs-by-name, impermanence,
                        homebrew, determinate, hjem). Each has:
                          flake-parts.nix  — declares inputs via `flake-file.inputs`,
                                             imports the tool's flake module(s)
                          <tool>.nix       — the actual module fragment(s)
  factory/<name>/       Parametric fragment functions (factory.user, factory.mountCifsNixos).
  hosts/<host>/         Per-machine config. configuration.nix (defines the host's
                        nixos fragment), flake-parts.nix (registers the system via
                        mkNixos), hardware.nix, users/<user>.nix.
  users/<user>/         User fragments: <user>.nix (adds groups + Hjem home config
                        on top of factory.user).
  programs/<category>/  Program categories (browser, cli, dev, editor, media, …).
                        A category master file (e.g. browser.nix) imports the
                        per-program files in its folder (helium.nix, vivaldi.nix).
  services/<service>.nix  Services (ssh, tailscale). Flat, one file each, no subdirs.
  system/
    settings/<area>/    System-level settings populated by area (bluetooth, bootloader,
                        firmware, network, systemd, system-constants).
    types/<type>/       System archetypes that compose categories + settings into a
                        baseline (desktop, server, dev). Hosts import one.
  wrappers/             Program wrappers (see below).
  options.nix           Top-level custom options (system.defaultApps, system.shell, …).
packages/               Custom packages, auto-discovered by pkgs-by-name-for-flake-parts.
secrets/                agenix-rekey store: master.pub + per-host encrypted secrets.
update.sh               Build/switch wrapper.
```

## Conventions

### Style
- **Custom options / service names / attributes:** `camelCase`
  (`modules.dev.zed.enable`, `systemDesktop`, `systemConstants`).
- **File and directory names:** `kebab-case` (`system-dev.nix`, `mount-cifs-nixos/`).
- Fragment names referenced via `self.modules.*` are `camelCase` even when the file
  is kebab-case (file `system-desktop.nix` → fragment `systemDesktop`).

### Custom options
- Feature toggles live under the `modules.*` namespace, defined alongside the module
  that consumes them, gated with `lib.mkIf`:
  ```nix
  options.modules.browser.helium.enable = lib.mkEnableOption "Helium browser";
  config = lib.mkIf cfg.enable { … };
  ```
- Cross-cutting options go in [modules/options.nix](modules/options.nix)
  (`system.defaultApps`, `system.shell`, `system.autoStart`).
- Hosts/types flip these toggles (`modules.dev.enable = true;`).

### Cross-platform fragments
Define both `flake.modules.nixos.<name>` and `flake.modules.darwin.<name>` when a
concern spans platforms; factor the shared body into a `let` helper rather than
duplicating. See [modules/programs/dev/dev.nix](modules/programs/dev/dev.nix) and
[modules/programs/cli/cli.nix](modules/programs/cli/cli.nix).

## Wrappers

[modules/wrappers/](modules/wrappers) builds configured program packages via two
toolkits: [Lassulus/wrappers](https://github.com/Lassulus/wrappers) and
[BirdeeHub/nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules).
Each wrapper produces a `perSystem.packages.<name>` (e.g. `git`, `neovim`,
`caelestia`). Flat (`<wrapper>.nix`) unless it ships external config files, then a
folder (`neovim/`, `quickshell/`). Shared shell aliases/vars live in
[shell-common.nix](modules/wrappers/shell-common.nix) (`flake.shellCommon`),
consumed by the zsh/bash wrappers and the Hjem-managed fish config (see
[Home directories](#home-directories-hjem)).

The neovim wrapper supports a `test_mode`/`devMode` that reads the live on-disk Lua
config under `modules/wrappers/neovim/` for fast iteration without a rebuild.

## Packages & external sources

- **In-repo packages:** drop them in [packages/](packages) — auto-exposed as
  `self.packages.<system>.<name>` (referred to as `selfpkgs` in modules) via
  pkgs-by-name; the overlay is applied through `flake.modules.generic.pkgsByName`.
- **My external flake (anynix):** input `anynix` =
  `git+https://codeberg.org/makila/anynix`. Use `inputs.anynix.packages.<system>.<pkg>`
  for packages and `anynix.program.<name>` / `inputs.anynix.default` for its modules.
  Package new external/proprietary apps there, not here.

## Home directories (Hjem)

**Do not use Home Manager.** Per-user home directories, dotfiles, and per-user
packages are managed with [Hjem](https://github.com/feel-co/hjem), wired via the
`hjem` tool fragment ([modules/nix/tools/hjem/](modules/nix/tools/hjem)).

- Hjem's module is **not safe to import more than once**, so it is imported once per
  system by `mkNixos`/`mkDarwin` (both classes); `factory.user` then only enables
  `hjem.users.<user>` (its `directory`/`user` are derived from `users.users.<user>`).
  Fragments (e.g. `fish`) only *set* `hjem.*` options — they must never import Hjem.
- Shared shell config: fish is Hjem-managed on **both** NixOS and darwin —
  [modules/programs/shell/fish.nix](modules/programs/shell/fish.nix) writes
  `~/.config/fish/config.fish` (from `shellCommon`) into every Hjem user via
  `hjem.extraModules`, with a plain `programs.fish` (no wrapped fish package). Both
  `systemDesktop` and `systemDev` import the `fish` fragment.
- Add home config *inside* a nixos/darwin fragment (there is no separate home class):
  ```nix
  hjem.users.marcus = {
    packages = with pkgs; [ ripgrep fd ];
    files.".config/foo".text = "hello";
    environment.sessionVariables.EDITOR = "nvim";
  };
  ```
- On darwin, Hjem links files/apps via launchd user agents (no systemd); its default
  `smfh` linker works cross-platform. `system.primaryUser` must be set — `factory.user`
  sets it for admin users.

## Secrets

agenix + [agenix-rekey](https://github.com/oddlama/agenix-rekey). The `secrets`
fragment ([modules/nix/tools/secrets/secrets.nix](modules/nix/tools/secrets/secrets.nix))
wires the modules and the rekey master identity; encrypted secrets live in
[secrets/](secrets) per host. Hosts that use secrets import the `secrets` fragment
and set `age.rekey.hostPubkey`.

## Adding things

- **New program:** add `modules/programs/<category>/<prog>.nix` defining
  `flake.modules.nixos.<prog>` (+ darwin if relevant), then import it from the
  category master file. import-tree picks up the file automatically.
- **New host:** create `modules/hosts/<host>/` with `configuration.nix` (host
  fragment importing a system type + settings) and `flake-parts.nix` (calls
  `mkNixos`/`mkDarwin`).
- **New flake input:** add it directly to the `inputs = { … }` block in `flake.nix`.
  Do **not** run `nix run .#write-flake` — flake.nix is not fully generated yet, and
  write-flake would drop the inputs that are maintained there by hand. (Tool modules
  under `modules/nix/tools/` also mirror their inputs in `flake-file.inputs` blocks for
  an eventual full migration; you may add one for symmetry, but flake.nix is the source
  of truth for now.)

## Building

Use [update.sh](update.sh) (must not run as root; targets the current hostname):

```
./update.sh -i           # rebuild + switch (impure)
./update.sh -i -u        # update flake inputs, then rebuild + switch
./update.sh -b           # build for next boot;  -t = temporary test;  -h NAME = host
```
