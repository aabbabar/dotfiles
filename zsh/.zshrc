# prompt
fpath+=($HOME/.zsh/pure)
[[ -d "${ZSH_PURE_SITE_FUNCTIONS:-}" ]] &&
  fpath+=("$ZSH_PURE_SITE_FUNCTIONS")
autoload -U promptinit; promptinit
prompt pure

# history
HISTSIZE=1000000000
SAVEHIST=1000000000
HISTFILE="${XDG_CACHE_HOME:-$HOME}/.zsh_history"
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space
setopt hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# cmp
zmodload zsh/complist
autoload -U compinit && compinit
if command -v workmux >/dev/null 2>&1; then
  source <(workmux completions zsh)
fi
autoload -U colors && colors
zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33

# opts
setopt auto_menu menu_complete autocd auto_param_slash
setopt no_case_glob no_case_match globdots
setopt always_to_end
unsetopt complete_in_word

# binds
bindkey -v # vim mode
bindkey "^n" history-search-forward
bindkey "^p" history-search-backward

# fzf
export FZF_CTRL_R_OPTS='--height 50% --reverse --prompt="> "'
source <(fzf --zsh)
bindkey '^R' fzf-history-widget

# alias
alias c='clear'
alias l='ls -lah --color'
alias v='nvim'

alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gfa='git fetch --all'
alias gfo='git fetch origin'
alias glog='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull --rebase'
alias gr='git reset'
alias grh='git reset --hard'
alias grbi='git rebase --interactive'
alias grbom='git rebase origin/master'
alias gst='git status'

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -g .......='../../../../../..'
alias -g ........='../../../../../../..'

# plugins
if [[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -n "${ZSH_SYNTAX_HIGHLIGHTING:-}" && -f "$ZSH_SYNTAX_HIGHLIGHTING" ]]; then
  source "$ZSH_SYNTAX_HIGHLIGHTING"
fi
source ~/.zsh/git-fzf.zsh
[[ -f ~/.zsh/worktrees.zsh ]] && source ~/.zsh/worktrees.zsh
eval "$(zoxide init zsh)"

# env
export EDITOR=nvim
export VISUAL=nvim
export GIT_EDITOR=nvim
export PATH=$PATH:$HOME/.local/bin

# golang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
if command -v go >/dev/null 2>&1; then
  export GOROOT="$(go env GOROOT)"
fi

# machine-specific config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

