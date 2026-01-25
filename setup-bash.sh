#!/bin/bash

set -e

cat >> $HOME/.bashrc << 'EOF'

set -o vi
bind -m vi-command '"/": reverse-search-history'
bind -m vi-command '"H": beginning-of-line'
bind -m vi-command '"L": end-of-line'
bind -m vi-insert '"\C-l": clear-screen'

__git_branch_dirty() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

  local branch dirty
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    dirty="*"
  fi

  printf "%s%s" "$branch" "$dirty"
}

PS1='\[\e[35m\][\w]\[\e[0m\]\[\e[36m\]$(branch=$(__git_branch_dirty); [ -n "$branch" ] && echo "[$branch]")\[\e[0m\]=> '
EOF
