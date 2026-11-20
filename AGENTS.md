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
| `nvim/.config/nvim/**` | `~/.config/nvim/**` | stowed | via setup.sh |
| `sesh/.config/sesh/sesh.toml` | `~/.config/sesh/sesh.toml` | stowed | via setup.sh |
| `ghostty/.config/ghostty/config` | `~/.config/ghostty/config` | stowed | via setup.sh |
| `sway/.config/sway/config` | `~/.config/sway/config` | stowed | via setup.sh |
| `sway/.local/bin/sway-resize` | `~/.local/bin/sway-resize` | stowed (via sway pkg) | via setup.sh |
| `fuzzel/.config/fuzzel/fuzzel.ini` | `~/.config/fuzzel/fuzzel.ini` | stowed | via setup.sh |
| `mako/.config/mako/config` | `~/.config/mako/config` | stowed | via setup.sh |
| `gammastep/.config/gammastep/config.ini` | `~/.config/gammastep/config.ini` | stowed | via setup.sh |
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
- [x] laptop hardware (2026-11-17, generation 23): bluetooth
      (`hardware.bluetooth.enable`, frontend: bluetui TUI) + BT audio
      verified end-to-end (Nothing Ear (a) paired, streaming from
      LibreWolf); TLP with 85/90 charge thresholds on both batteries;
      thermald;       fwupd (manual-only; LVFS metadata confirms all firmware current);
      VA-API via `intel-media-driver` (iHD verified with vainfo; ~5% of
      8 cores during 1080p60 YouTube); rtkit; sway module extras trimmed
      to `brightnessctl` + `grim`; media-key binds added to the local
      sway config. fprintd N/A — this unit has no fingerprint reader
      (removed from scope). fstrim was already enabled (NixOS default).
      zram skipped (swap unused, fails "really required" test).
- [x] sway polish (2026-11-17): `sway` stow package created
      (`sway/.config/sway/config`, stowed on t480 — config now in the
      repo); idle/lock via swayidle: blank+lock after 10 min idle, dpms
      off 30s later, suspend after 30 min on battery / 60 min on AC,
      lock before sleep; screenshot binds (Print full-screen,
      Mod+Print region via slurp, saved to `~/img`); no status bar
      (user choice); TTY start kept — greetd declined (decision 11).
- [x] desktop session round (2026-11-20, generation 29): launcher
      fuzzel (gruvbox-styled ini, `Mod+d`; dmenu-mode for scripts);
      clipboard history via cliphist (`wl-paste --watch`) with
      instant-paste on `Mod+Shift+v` through ydotool (decision 13);
      notification daemon mako (decision 12, gruvbox theme);
      night light gammastep (decision 12, London manual coordinates);
      libnotify; sway input polish (decision 14); borderless windows +
      directional resize script (decision 15); keymap additions
      (decision 15); utilities btop, zathura, ripgrep, fd, jq
      (declined: yazi, lazygit, ncdu, wf-recorder); `linger = true`
      (decision 16). fnott and wtype removed after trials.
      Store hygiene: garbage-collected 29 accumulated generations
      older than 1 day, wiped trial configs and tmp artifacts.
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
7. FOSS-first policy for all software: investigate Free and Open Source
   options first; consider non-FOSS only if FOSS options are unsatisfactory
   or a non-FOSS alternative is far superior.
8. Browser: LibreWolf adopted on t480 (2026-11-17) as the general
   browsing browser; `ungoogled-chromium` adopted as the dedicated
   Google-account browser (Gmail/YouTube only — never general browsing)
   to keep Google cookies/fingerprint out of general browsing
   (compartmentalization). qutebrowser tried and liked — revisit after a
   fixed release (3.7.1+, with QtWebEngine 6.140+ eMudhra fix) reaches
   the 26.05 branch; until then it is marked insecure in nixpkgs and
   needs `permittedInsecurePackages` to adopt.
9. VPN: Mullvad via the CLI-only package (`services.mullvad-vpn.enable`;
   module default is the CLI tools, no GUI). Managed from the terminal:
   `mullvad account login`, `mullvad connect`, `mullvad status`.
10. Hardware baseline (2026-11-17): TLP with 85/90 charge thresholds on
    both batteries; bluetui as the BT frontend (no blueman/bluetoothctl
    as daily drivers); VA-API via `intel-media-driver`; fwupd enabled but
    manual-only (nothing runs automatically); no zram (swap unused);
    audio TUI is pulsemixer, network TUI is nmtui (both packaged; wpctl
    and nmcli remain the primary CLIs); sway module extras trimmed to
    `[brightnessctl grim slurp]` (foot/wmenu/pulseaudio tools dropped).
11. Sway session (2026-11-17): started from the TTY (no greetd — user
    declined; zero display manager); no status bar; idle/lock/suspend
    via swayidle timeouts; screenshots to `~/img` via grim (+slurp
    region). Machine-local quirk: media keys predate the stow package —
    now canonical in the repo config.
12. Desktop tools (2026-11-20): launcher is fuzzel (gruvbox-styled ini,
    icons off, dmenu-mode for script menus). Notification daemon is
    mako (gruvbox theme) — fnott was trialed alongside and dropped;
    mako preferred for its rules engine, grouping and history.
    Night light is gammastep (London, manual provider, 6500K/3000K) —
    wlsunset trialed and dropped (gammastep allows one-shot manual
    overrides: `-O`, `-g`, `-b`). Trial-by-usage: both candidates
    installed, verdict taken, loser removed in the same group.
13. Clipboard: history via cliphist fed by `wl-paste --watch`;
    instant-paste `Mod+Shift+v` = `cliphist list | fuzzel --dmenu |
    cliphist decode | ydotool type -d 0 -H 0 -f -`. ydotool replaced
    wtype, which mangled shift-modified characters in ghostty
    (wtype's virtual-keyboard keymap vs ghostty's multi-keyboard
    handling; no delay fixed it). ydotool types via evdev/uinput
    through ydotoold (`programs.ydotool.enable`; user in the
    `ydotool` group; group membership requires re-login, hence
    decision 16). Tradeoff: ASCII-only input.
14. Sway input/looks (2026-11-20): borderless (`default_border none`,
    `default_floating_border none`); trackpad tap-to-click with `lrm`
    map (2-finger right, 3-finger middle), natural scroll,
    `scroll_factor 0.5`, `pointer_accel 0.25` on touchpad + pointers,
    repeat 200/50, `caps:swapescape`.
15. Sway keymap (2026-11-20): a user config fully replaces sway's
    default keymap (no merging). Windows move with
    `$mod+Ctrl+hjkl`, resize via the directional script
    `sway-resize` on `$mod+Shift+hjkl` (divider always moves in the
    pressed direction, works per-axis for horizontal/vertical
    splits); split toggle `$mod+Ctrl+e`; workspace toggle only via
    `$mod+Tab` (`workspace back_and_forth`; no
    `workspace_auto_back_and_forth` — plain number keys are no-ops
    when already on target); lock `$mod+Ctrl+Shift+l`.
16. Linger (2026-11-20): `users.users.aabb.linger = true` — user
    manager survives logout, so tmux sessions (and opencode) persist
    across relogins; also required for ydotool group membership to
    apply without losing tmux state.

## Machine status

### t480 (NixOS)

- Running generation 29 from `~/dotfiles#t480` (nixpkgs 26.05.20261113):
  opencode 1.15.10, nvim toolchain (gcc, gnumake, tree-sitter), browsers
  (librewolf, ungoogled-chromium), mullvad-vpn, hardware baseline
  (bluetooth+bluetui, tlp, thermald, fwupd, intel-media-driver, rtkit,
  pulsemixer), desktop session (fuzzel, cliphist+ydotool, mako,
  gammastep, libnotify, wl-clipboard), utilities (btop, zathura,
  ripgrep, fd, jq), ydotool module + linger.
- Account shell is zsh (passwd correct).
- Known issue (Phase B root cause, verified 2026-11-16): the sway session
  exports a stale `SHELL=/run/current-system/sw/bin/bash`, inherited from a
  TTY login that predates the zsh switch. Ghostty honours `$SHELL` and the
  tmux server bakes it into `default-shell`, so fresh windows and panes run
  bash. Fix: full logout/relogin — no config change required.
- Session state 2026-11-17: Phase A complete and committed (847b17b).
  Phase B verified — zsh everywhere. C1 nvim compat fixes + toolchain
  rebuild applied and verified: 25 plugins, zero errors, six treesitter
  parsers installed with highlighting active, fzf-native built.
  LibreWolf + ungoogled-chromium + Mullvad VPN added and verified.
  Hardware baseline complete (generation 23, see Phase C + decision
  register item 10): bluetooth, TLP, thermald, fwupd, VA-API, rtkit;
  BT audio verified. Sway polish complete (see Phase C): config
  stowed, idle/lock/suspend via swayidle, screenshot binds.
- Session state 2026-11-20: desktop session round complete
  (generation 29, see Phase C + decisions 12–16): fuzzel launcher,
  cliphist history + ydotool instant-paste, mako, gammastep, sway
  input/borderless/resize polish, utilities, linger. Next:
  macOS hardening per Phase C.

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
