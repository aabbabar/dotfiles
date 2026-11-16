# T480 handover

## Goal and constraints

- Continue the T480 NixOS setup using `~/dotfiles#t480`.
- Do not reintroduce Home Manager for now. NixOS manages packages and system integration; GNU Stow links raw application configs.
- Keep shared app configs portable and preserve macOS behavior. Do not run `setup.sh` on the T480.
- Never display or copy `~/.config/gh/hosts.yml`; it contains the GitHub authentication token.

## Repository state

- Base checkpoint: `644cdf5 feat(nix): add stow and terminal tooling`.
- This handover and the OpenCode package addition are pending a commit/pull to the T480.
- `nix/hosts/t480/configuration.nix` is the T480's NixOS configuration.
- OpenCode is added as the `opencode` package from Nixpkgs 26.05. That branch provides version `1.15.10` for `x86_64-linux`.

## Current setup

- The system config enables zsh as the account shell and installs terminal tools through `environment.systemPackages`.
- NixOS exports `ZSH_PURE_SITE_FUNCTIONS` and `ZSH_SYNTAX_HIGHLIGHTING` in `programs.zsh.interactiveShellInit`. The raw zsh config loads these when available and retains macOS plugin-path fallbacks.
- `programs.zsh.enableGlobalCompInit = false` because the raw `zsh/.zshrc` initializes completion itself.
- Stow packages currently use native paths:
  - `zsh/.zshrc`
  - `zsh/.zsh/git-fzf.zsh`
  - `tmux/.tmux.conf`
- `workmux/worktrees.zsh` is deferred and is not part of the Linux zsh Stow package.
- Home Manager was removed from the flake. Its old symlinks under `$HOME` do not disappear automatically when its module is removed.

## Reported validation

- A NixOS rebuild and switch completed after moving the zsh plugin-path exports into interactive zsh initialization; the user confirmed those paths then worked.
- Stow dry-run showed the expected `.zsh`, `.zshrc`, and `.tmux.conf` links; Stow was applied.
- The user confirmed the Pure prompt, tmux prefix, and fzf Ctrl-R work outside tmux.
- Old Home Manager links were found under `.zshrc` and `.config`. The user reports cleaning these up while preserving `~/.config/gh/hosts.yml`.
- macOS symlinks were repointed to the moved source files; zsh and tmux received local smoke tests.

## Unresolved: shell selection

After cleaning Home Manager artifacts, the user reports that a fresh Ghostty window now starts Bash. Earlier, Ghostty had started zsh with the Pure prompt. The cause is not yet known. The user also reports Ctrl-R inside tmux invokes reverse history search.

On the T480, distinguish the account shell, inherited `SHELL`, and the running shell process before changing anything:

```sh
printf 'SHELL=%s\n' "$SHELL"
printf 'account shell: '; getent passwd "$USER" | cut -d: -f7
printf 'running process: '; ps -p $$ -o comm=
```

Inspect Ghostty's command override only if the account shell and running process disagree. If the account shell is Bash despite the NixOS setting, investigate NixOS mutable-user behavior and update it deliberately. Do not assume the tmux server is the cause until Ghostty's shell is confirmed.

## Next steps

1. Pull the commit containing this handover and OpenCode, then build and switch with `sudo nixos-rebuild switch --flake ~/dotfiles#t480`.
2. Verify `opencode --version` and launch `opencode`. Configure a provider locally if needed; keep credentials out of Git and Nix expressions.
3. Diagnose and restore zsh in a fresh Ghostty session; then re-test zsh prompt, fzf, and tmux Ctrl-R.
4. Continue with Neovim's NixOS compatibility after the terminal setup is stable.
