# CLAUDE.md

NixOS + nix-darwin configuration built on the **dendritic pattern**: every `.nix`
file under `modules/` is a [flake-parts](https://github.com/hercules-ci/flake-parts)
module, auto-imported by [import-tree](https://github.com/vic/import-tree). There
are no manual import lists in `flake.nix` — adding a file *is* wiring it in.

## Architecture

### The dendritic pattern

- `flake.nix` is **generated** by [flake-file](https://github.com/vic/flake-file) —
  do not hand-edit it. Its body is `inputs.import-tree ./modules`, so every `.nix`
  file in `modules/` is loaded as a flake-parts module.
- Each module is a function `{ inputs, lib, self, config, ... }: { ... }`. Instead
  of producing a host config directly, modules contribute **named, reusable module
  fragments** to the flake:
  - `flake.modules.nixos.<name>` — a NixOS module
  - `flake.modules.darwin.<name>` — a nix-darwin module
  - `flake.modules.homeManager.<name>` — a Home Manager module
  - `flake.modules.generic.<name>` — module usable across classes
  - `perSystem.packages.<name>` — a package (wrappers, custom builds)
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
config.flake.factory.user = username: isAdmin: { nixos.${username} = …; darwin.… ; homeManager.… };

# use — modules/users/marcus/marcus.nix
flake.modules = lib.mkMerge [ (self.factory.user "marcus" true) { … } ];
```

### Host assembly helpers

`flake.lib.{mkNixos,mkDarwin,mkHome}` (in [modules/nix/flake-parts/lib.nix](modules/nix/flake-parts/lib.nix))
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
                        homebrew, determinate). Each has:
                          flake-parts.nix  — declares inputs via `flake-file.inputs`,
                                             imports the tool's flake module(s)
                          <tool>.nix       — the actual module fragment(s)
  factory/<name>/       Parametric fragment functions (factory.user, factory.mountCifsNixos).
  hosts/<host>/         Per-machine config. configuration.nix (defines the host's
                        nixos fragment), flake-parts.nix (registers the system via
                        mkNixos), hardware.nix, users/<user>.nix.
  users/<user>/         User fragments: <user>.nix + flake-parts.nix (home configs).
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
consumed by the fish/zsh/bash wrappers.

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
- **New flake input:** add a `flake-file.inputs = { … };` block in the relevant
  module (tool modules under `modules/nix/tools/` are the usual home), then
  **regenerate** `flake.nix` with `nix run .#write-flake`. Never edit `flake.nix`
  directly.

## Building

Use [update.sh](update.sh) (must not run as root; targets the current hostname):

```
./update.sh -i           # rebuild + switch (impure)
./update.sh -i -u        # update flake inputs, then rebuild + switch
./update.sh -b           # build for next boot;  -t = temporary test;  -h NAME = host
```
