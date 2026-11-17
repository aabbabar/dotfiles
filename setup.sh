#!/bin/bash
set -e

is_dotfiles_link() {
  local link="$1" value abs
  [[ -L "$link" ]] || return 1
  value="$(readlink "$link")"
  case "$value" in
    /*) abs="$value" ;;
    *)  abs="$(cd "$(dirname "$link")" && pwd)/$value" ;;
  esac
  [[ "$abs" == "$HOME/dotfiles" || "$abs" == "$HOME/dotfiles/"* ]]
}

link_config() {
  local source="$1" target="$2"
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    return
  fi
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "Refusing to overwrite $target; back it up before running setup." >&2
    exit 1
  fi
  if [[ -L "$target" ]] && ! is_dotfiles_link "$target"; then
    echo "Refusing to overwrite $target; it is not managed by dotfiles." >&2
    exit 1
  fi
  if [[ -L "$target" ]]; then
    echo "Re-pointing $target -> $source"
    rm "$target"
  fi
  ln -s "$source" "$target"
}

echo "==> Symlinking zshrc"
link_config "$HOME/dotfiles/zsh/.zshrc" "$HOME/.zshrc"

echo "==> Symlinking zsh scripts"
mkdir -p ~/.zsh
link_config "$HOME/dotfiles/zsh/.zsh/git-fzf.zsh" "$HOME/.zsh/git-fzf.zsh"
link_config "$HOME/dotfiles/workmux/.zsh/worktrees.zsh" "$HOME/.zsh/worktrees.zsh"

echo "==> Symlinking session configuration"
mkdir -p ~/.config/sesh
link_config "$HOME/dotfiles/sesh/.config/sesh/sesh.toml" "$HOME/.config/sesh/sesh.toml"

echo "==> Symlinking workmux configuration"
mkdir -p ~/.config/workmux
link_config "$HOME/dotfiles/workmux/.config/workmux/config.yaml" "$HOME/.config/workmux/config.yaml"
link_config "$HOME/dotfiles/workmux/.config/workmux/bare.yaml" "$HOME/.config/workmux/bare.yaml"

echo "==> Symlinking Copilot status hooks"
mkdir -p ~/.copilot/hooks
link_config "$HOME/dotfiles/workmux/.copilot/hooks/workmux-status.json" "$HOME/.copilot/hooks/workmux-status.json"

echo "==> Symlinking ghostty configuration"
mkdir -p ~/.config/ghostty
link_config "$HOME/dotfiles/ghostty/.config/ghostty/config" "$HOME/.config/ghostty/config"

echo "==> Cloning plugin repos"
[ -d ~/.zsh/zsh-syntax-highlighting ] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

[ -d ~/.zsh/pure ] || \
  git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure

echo "==> Symlinking nvim config"
mkdir -p ~/.config
link_config "$HOME/dotfiles/nvim/.config/nvim" "$HOME/.config/nvim"

echo "==> Symlinking tmux config"
link_config "$HOME/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"

echo "==> Done!"
