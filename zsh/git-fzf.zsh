git_branch_checkout_fzf() {
  emulate -L zsh
  setopt pipefail

  # Ensure we're in a git repo
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    zle -M "Not a git repository."
    return 1
  fi

  # Ensure fzf exists
  if ! command -v fzf >/dev/null 2>&1; then
    zle -M "fzf not found. Install it first."
    return 1
  fi

  # (Optional) refresh remotes quickly and quietly
  # command git fetch -pq --all >/dev/null 2>&1

  # Build a tab-separated list: BRANCH<TAB>SHORT_SHA<TAB>AGE<TAB>AUTHOR<TAB>SUBJECT
  # Includes local (refs/heads) and remote (refs/remotes), excludes remote HEAD aliases.
  local list selected branch
  list=$(
    git for-each-ref --sort=-committerdate \
      --format='%(refname:short)' \
      refs/heads refs/remotes \
    | grep -vE '^[^/]+/HEAD$'
  ) || return

  # Open fzf
  selected=$(
    print -r -- "$list" | fzf --no-multi --height=50% --layout=reverse --ansi \
      --prompt='branches> ' \
  ) || return

  # Extract the branch name (first column)
  branch="${selected%%$'\t'*}"
  [[ -z "$branch" ]] && return 1

  # If it's an existing local branch, just switch to it
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    if git switch "$branch"; then
      zle -M "Switched to $branch"
      zle -I          # clear any pending input
      BUFFER=''       # make sure nothing is executed
      zle accept-line # simulate pressing Enter
    fi
    return
  fi

  # If it's a remote (like origin/feature/x), create a local tracking branch
  if [[ "$branch" == */* ]]; then
    if git switch --track "$branch" 2>/dev/null; then
      zle -M "Created local branch tracking $branch"
      zle -I          # clear any pending input
      BUFFER=''       # make sure nothing is executed
      zle accept-line # simulate pressing Enter
      return
    fi
    # Fallback: create with explicit local name after the first slash
    local localname="${branch#*/}"
    if git switch -c "$localname" --track "$branch"; then
      zle -M "Created '$localname' tracking $branch"
      zle -I          # clear any pending input
      BUFFER=''       # make sure nothing is executed
      zle accept-line # simulate pressing Enter
      return
    fi
    return 1
  fi

  # Otherwise, create a new local branch from current HEAD
  if git switch -c "$branch"; then
    zle -M "Created and switched to $branch"
    zle -I          # clear any pending input
    BUFFER=''       # make sure nothing is executed
    zle accept-line # simulate pressing Enter
  fi
}
zle -N git_branch_checkout_fzf
bindkey '^G' git_branch_checkout_fzf


