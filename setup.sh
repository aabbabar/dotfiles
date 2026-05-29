#!/bin/bash
set -e

echo "==> Symlinking zshrc"
ln -sf ~/dotfiles/zsh/zshrc ~/.zshrc

echo "==> Symlinking zsh scripts"
mkdir -p ~/.zsh
ln -sf ~/dotfiles/zsh/git-fzf.zsh ~/.zsh/git-fzf.zsh

echo "==> Cloning plugin repos"
[ -d ~/.zsh/zsh-syntax-highlighting ] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

[ -d ~/.zsh/pure ] || \
  git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure

echo "==> Symlinking nvim config"
mkdir -p ~/.config
ln -sf ~/dotfiles/nvim ~/.config/nvim

echo "==> Symlinking tmux config"
ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf

echo "==> Done!"
