gcln() {
  emulate -L zsh

  if (( $# != 1 )); then
    print -u2 -- "Usage: gcln <remote-url>"
    return 2
  fi

  local remote="$1"
  local repository="${${remote%/}:t}"
  repository="${repository%.git}"
  if [[ -z "$repository" || "$repository" == "." || "$repository" == ".." ]]; then
    print -u2 -- "gcln: could not derive a repository name from: $remote"
    return 2
  fi

  local root="$HOME/bbc/$repository"
  local bare="$root/.bare"
  local config="$HOME/.config/workmux/bare.yaml"
  local default_branch
  if [[ ! -r "$config" ]]; then
    print -u2 -- "gcln: missing $config; run dotfiles/setup.sh first"
    return 1
  fi
  if [[ -e "$root" || -L "$root" ]]; then
    print -u2 -- "gcln: destination already exists: $root"
    return 1
  fi

  mkdir -p -- "$root" || return 1
  if ! git clone --bare "$remote" "$bare"; then
    print -u2 -- "gcln: clone failed; inspect or remove $root before retrying"
    return 1
  fi
  git --git-dir="$bare" config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*' || return 1
  git --git-dir="$bare" fetch --prune origin || return 1
  git --git-dir="$bare" remote set-head origin --auto || return 1
  default_branch="$(git --git-dir="$bare" symbolic-ref --quiet --short refs/remotes/origin/HEAD)" || return 1
  default_branch="${default_branch#origin/}"

  git --git-dir="$bare" worktree add "$root/main" "$default_branch" || return 1
  mkdir -p -- "$root/worktrees" || return 1
  ln -s "$config" "$bare/.workmux.yaml" || return 1
  cd -- "$root/main" || return 1
  print -- "gcln: ready in $PWD"
}
