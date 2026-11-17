# AGENTS.md

Living document for agents and humans working in this repo. Read this first,
and update it as work completes — it is the handover mechanism between
sessions.

## Repo purpose

Shared dotfiles for two machines:

| Machine | OS | Role |
|---|---|---|
| t480 | NixOS 26.05 (flake: `~/dotfiles#t480`) | primary, active work |
| macbook | macOS | secondary, shares app configs |

Philosophy:

- NixOS owns the system (`nix/hosts/t480/`), configured via the flake.
- GNU Stow owns the `$HOME` configs, one package per application.
- No Home Manager (deliberate — do not reintroduce).
- `setup.sh` is the macOS bridge until stow is adopted there. It is
  deprecated on Linux — never run it on the t480.

## Canonical pattern: mirror-$HOME (locked 2026-11-17)

1. One stow package per application, named after the app (`zsh`, `tmux`,
   `nvim`, `sesh`, `ghostty`, `workmux`).
2. Package contents are the literal relative paths from `$HOME` — the repo
   mirrors `$HOME`.
3. One uniform command, no per-package targets:
   `stow -d ~/dotfiles -t ~ <pkg>`.
4. Non-`$HOME` content is never a package: `nix/`, `flake.*`, `setup.sh`,
   this file.

Considered and deferred: migrating zsh/tmux fully under `~/.config`
(zsh via `ZDOTDIR` shim, tmux via its XDG conf path). Revisit only as a
deliberate future migration.

## Package map

| Package | Stows to | t480 | macOS |
|---|---|---|---|
| `zsh/.zshrc` | `~/.zshrc` | stowed | linked |
| `zsh/.zsh/git-fzf.zsh` | `~/.zsh/git-fzf.zsh` | stowed | linked |
| `tmux/.tmux.conf` | `~/.tmux.conf` | stowed | linked |
| `nvim/.config/nvim/**` | `~/.config/nvim/**` | pending A5 | via setup.sh |
| `sesh/.config/sesh/sesh.toml` | `~/.config/sesh/sesh.toml` | pending A5 | via setup.sh |
| `ghostty/.config/ghostty/config` | `~/.config/ghostty/config` | pending A5 | via setup.sh |
| `workmux/**` | `~/.config/workmux/**`, `~/.zsh/worktrees.zsh`, `~/.copilot/hooks/workmux-status.json` | not stowed (deferred) | via setup.sh |

## Agent rules (binding)

- **Never author commits.** Make changes, suggest commit messages, and wait
  for the user to commit. Execute one commit-group at a time, then stop.
- Never display or copy `~/.config/gh/hosts.yml` — it contains the GitHub
  auth token.
- Keep credentials and secrets out of the repo and Nix expressions.
- Stow: always dry-run first (`-n -v`); expect zero conflicts before applying.
- Update this doc as work completes.

## Commands

```sh
# NixOS rebuild
sudo nixos-rebuild switch --flake ~/dotfiles#t480

# Stow
stow -d ~/dotfiles -t ~ -n -v <pkg>   # dry-run
stow -d ~/dotfiles -t ~ <pkg>         # apply
stow -d ~/dotfiles -t ~ -D <pkg>     # unstow
```

## Roadmap

### Phase A — repo restructure + stow on t480

- [x] A1 hygiene: gitignore `result`; drop superseded stash; remove
      `~/rebuild.log` and `~/.config/ghostty/config.ghostty`
- [x] A2 this doc; fold in and delete `nix/hosts/t480/HANDOVER.md`
- [x] A3 restructure all packages to mirror-$HOME; update `setup.sh`
      (safe re-pointing of dotfiles-owned links); add ghostty skeleton
- [x] A5 stow `nvim`/`sesh`/`ghostty` on t480; nvim smoke test
      (copilot.nvim not used on t480; nodejs deliberately not installed)

### Phase B — shell fix (user action)

- [x] Full logout/relogin to clear stale `SHELL=bash` — verified
      2026-11-17: `$SHELL` and tmux `default-shell` both zsh

### Phase C — backlog (priority order)

- [x] nvim compat fixes (2026-11-17): telescope spec import (require
      moved inside config), keymaps made lazy-safe via closures,
      treesitter ported to the rewritten `main`-branch API (`install()` +
      FileType autocmd with `vim.treesitter.start()`). Verified clean on
      a fresh install: 25 plugins, zero errors.
- [x] t480 toolchain for nvim extras (2026-11-17, generation 21):
      `tree-sitter` + `gcc` (parser builds invoke `tree-sitter build`, which
      needs a C compiler) and `gnumake` (telescope-fzf-native build step).
      All six parsers installed and highlighting verified active;
      fzf-native built (`libfzf.so`).
- [ ] laptop hardware: bluetooth, fprintd, TLP/power management, fstrim,
      thermald, fwupd
- [ ] sway polish: config package, idle/lock behaviour, greetd?
- [ ] macOS hardening: re-run updated `setup.sh` (re-points links), adopt
      stow, then deprecate `setup.sh`
- [ ] optional: sesh packaging (2.26.2 is in nixpkgs); workmux port
      (source: github raine/workmux)

## Decision register

1. Pattern: mirror-$HOME (rules above). All-XDG migration deferred.
2. Shell fix: restart-only, no config pinning of shells.
3. Restructure: all packages at once.
4. Tracker: this file; supersedes `nix/hosts/t480/HANDOVER.md`.
5. Agents never author commits — suggest messages only; the user commits.
6. t480 priorities: nvim compat, laptop hardware, sway polish. sesh stays
   uninstalled (config-only). workmux deferred. No Home Manager.

## Machine status

### t480 (NixOS)

- Running generation 21 from `~/dotfiles#t480` (nixpkgs 26.05.20261113):
  opencode 1.15.10, nvim toolchain (gcc, gnumake, tree-sitter).
- Account shell is zsh (passwd correct).
- Known issue (Phase B root cause, verified 2026-11-16): the sway session
  exports a stale `SHELL=/run/current-system/sw/bin/bash`, inherited from a
  TTY login that predates the zsh switch. Ghostty honours `$SHELL` and the
  tmux server bakes it into `default-shell`, so fresh windows and panes run
  bash. Fix: full logout/relogin — no config change required.
- Session state 2026-11-17: Phase A complete and committed (847b17b).
  Phase B verified — zsh everywhere. C1 nvim compat fixes + toolchain
  rebuild (generation 21) applied and verified: 25 plugins, zero
  errors, six treesitter parsers installed with highlighting active,
  fzf-native built. Next: laptop hardware and sway polish per Phase C.

### macOS

- zsh/tmux links repointed to the repo and valid (unaffected by A3).
- After A3 lands: nvim/sesh/workmux/copilot links break until the updated
  `setup.sh` is re-run there (it now re-points dotfiles-owned links safely).

## Phase B instructions (t480 shell fix)

```sh
tmux kill-server   # kills running tmux panes and any opencode session
# then: exit sway, log out of the TTY session completely,
#       log back in, start sway
```

Verify after restart:

```sh
echo $SHELL                      # /run/current-system/sw/bin/zsh
tmux show -g default-shell       # zsh (fresh tmux server)
```

Fresh Ghostty window should show the pure prompt, and Ctrl-R inside tmux
should invoke the fzf history widget.
