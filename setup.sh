#!/bin/bash
set -e

link_config() {
  local source="$1" target="$2"
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    return
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    echo "Refusing to overwrite $target; back it up before running setup." >&2
    exit 1
  fi
  ln -s "$source" "$target"
}

echo "==> Symlinking zshrc"
link_config "$HOME/dotfiles/zsh/zshrc" "$HOME/.zshrc"

echo "==> Symlinking zsh scripts"
mkdir -p ~/.zsh
link_config "$HOME/dotfiles/zsh/git-fzf.zsh" "$HOME/.zsh/git-fzf.zsh"

echo "==> Symlinking session configuration"
mkdir -p ~/.config/sesh
link_config "$HOME/dotfiles/sesh/sesh.toml" "$HOME/.config/sesh/sesh.toml"

echo "==> Cloning plugin repos"
[ -d ~/.zsh/zsh-syntax-highlighting ] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

[ -d ~/.zsh/pure ] || \
  git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure

echo "==> Symlinking nvim config"
mkdir -p ~/.config
link_config "$HOME/dotfiles/nvim" "$HOME/.config/nvim"

echo "==> Symlinking tmux config"
link_config "$HOME/dotfiles/tmux/tmux.conf" "$HOME/.tmux.conf"

echo "==> Done!"
