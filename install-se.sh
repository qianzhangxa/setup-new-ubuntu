#!/bin/bash

set -e

ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="amd64"
elif [[ "$ARCH" == "aarch64" ]]; then
    ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

echo -e "\n===== Install zsh =====\n"
sudo apt update
sudo apt install -y zsh

echo -e "\n===== Install and customize oh-my-zsh =====\n"
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cat > $HOME/.oh-my-zsh/themes/qzhang.zsh-theme << 'EOF'
# RVM settings
if [[ -s ~/.rvm/scripts/rvm ]] ; then 
  RPS1="%{$fg[yellow]%}rvm:%{$reset_color%}%{$fg[red]%}\$(~/.rvm/bin/rvm-prompt)%{$reset_color%} $EPS1"
else
  if which rbenv &> /dev/null; then
    RPS1="%{$fg[yellow]%}rbenv:%{$reset_color%}%{$fg[red]%}\$(rbenv version | sed -e 's/ (set.*$//')%{$reset_color%} $EPS1"
  fi
fi

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$bg[red]%}%{$fg_bold[white]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%{$bg[red]%}%{$fg_bold[white]%}]"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[yellow]%}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# Customized git status, oh-my-zsh currently does not allow render dirty status before branch
git_custom_status() {
  local cb=$(git_current_branch)
  if [ -n "$cb" ]; then
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

PROMPT='%{$bg[magenta]%}%{$fg_bold[white]%}[%~% ]$(git_custom_status)%{$reset_color%}%(?:%{$fg_bold[white]%}=>:%{$fg_bold[red]%}=>)%{$reset_color%} '
EOF

GIT_PLUGIN_FILE="$HOME/.oh-my-zsh/plugins/git/git.plugin.zsh"
sed -i "s/^alias gsh='git show'/alias gs='git show'/" "$GIT_PLUGIN_FILE"
sed -i "/^alias gd=/a alias gdh='git diff HEAD^'" "$GIT_PLUGIN_FILE"
sed -i "/^alias gke=/a alias gldg='git log --decorate --graph --oneline --all'" "$GIT_PLUGIN_FILE"
sed -i "/^alias gke=/a alias gfum='git fetch upstream \$(git_main_branch)'" "$GIT_PLUGIN_FILE"

echo -e  "\n===== Add pls and nls =====\n"
mkdir $HOME/bin

cat > $HOME/bin/nls << 'EOF'
#!/bin/sh

if [ $# -eq 0 ]; then
    sudo netstat -anp | grep "\<LISTEN\>"
else
    sudo netstat -anp | grep "\<LISTEN\>" | grep ":$1"
fi
EOF

cat > $HOME/bin/pls << 'EOF'
#!/bin/sh

if [ $# -eq 0 ]; then
    ps -ef
else
    ps -ef | grep $1 | grep -v "pls\|grep"
fi
EOF

chmod +x $HOME/bin/nls $HOME/bin/pls

echo -e "\n===== Install some utilities =====\n"
sudo apt install -y tree bat net-tools moreutils
ln -s /usr/bin/batcat $HOME/bin/bat

echo -e "\n===== Add .vimrc =====\n"
cat > $HOME/.vimrc << 'EOF'
set nocompatible

set shiftwidth=2
set sts=2
set tabstop=2

set autoindent
set cindent

set ruler
set rulerformat=%25(%5l,%-6(%c%V%)\ %P%)

map L $
map H ^
map ; <C-E>
map ' <C-Y>
map <Space> <C-F>
map <S-Space> <C-B>

syntax enable

colorscheme koehler
highlight Normal ctermbg=NONE guibg=NONE

set t_ti= t_te=

set expandtab
set nobackup
set nowritebackup
set hlsearch

" When editing a file, always jump to the last cursor position
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Install Vim plugin manager
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Install the vim-commentary plugin
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-commentary'
call plug#end()
EOF

echo -e "\n===== Customize .zshrc =====\n"
ZSHRC_FILE="$HOME/.zshrc"

sed -i 's/^ZSH_THEME=.*/ZSH_THEME="qzhang"/' "$ZSHRC_FILE"

cat >> "$ZSHRC_FILE" << 'EOF'

alias ll='ls -lAh'
alias la='ls -Ah'
alias l='ls -lh'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias svi='sudo -E vim'
alias date="date '+%Y-%m-%d %H:%M:%S %Z %z'"

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

export LS_COLORS=$LS_COLORS:'di=1;37;44'
zstyle ':completion:*' list-colors 'di=1;37;44'
zstyle ':completion:*' insert-tab pending-off

# Enable vi mode and custom keybindings
set -o vi
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd 'H' beginning-of-line
bindkey -M vicmd 'L' end-of-line

# Ensure the new file created with -rw-r--r--
umask 022

unsetopt sharehistory

export PATH=$PATH:$HOME/bin:/usr/local/go/bin:$HOME/go/bin
EOF

echo -e "\n===== Please run zsh now ====="
