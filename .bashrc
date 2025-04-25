set -o vi
bind -m vi-command '"/": reverse-search-history'
bind -m vi-command '"H": beginning-of-line'
bind -m vi-command '"L": end-of-line'
bind -m vi-command '"dL": kill-line'
bind -m vi-command '"dH": "\C-u"'
bind -m vi-insert '"\C-l": clear-screen'

function git_custom_status {
    git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -n "$git_branch" ]]; then
        echo " [$git_branch]"
    fi
}

function set_prompt {
    local exit_code=$?
    local arrow_color="\[\e[1;37m\]" # white
    [[ $exit_code -ne 0 ]] && arrow_color="\[\e[1;31m\]" # red if error

    PS1="\[\e[46m\]\[\e[1;37m\][\w]$(git_custom_status)\[\e[0m\]$arrow_color=>\[\e[0m\] "
}

PROMPT_COMMAND=set_prompt

alias ll='ls -lAh'
alias la='ls -Ah'
alias l='ls -lh'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias dp='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dia='docker images -a'
alias dis='docker inspect'
alias dr='docker run'
alias drr='docker run --rm'
alias drm='docker rm'
alias drmi='docker rmi'
alias da='docker attach'
alias ds='docker start'
alias dsp='docker stop'
alias de='docker exec'
alias dl='docker logs'
alias db='docker build'

export LS_COLORS="$LS_COLORS:di=1;37;104"
