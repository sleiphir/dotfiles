# Enable vi mode
bindkey -v

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

ZSH_THEME="robbyrussell"

plugins=(
    vi-mode
	git
	zsh-autosuggestions
	sudo
    fzf
)

source $ZSH/oh-my-zsh.sh

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

alias ls='eza --icons --grid --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group' # ls
alias ll='eza -lbF --git' # list, size, type, git
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias cat='bat'
alias grepw='grep -rnw $(pwd) -e'
alias grepc='grep -rn $(pwd) -e'
alias grepex=_grepex $1
# alias fzf_pass="find $HOME/.password-store -type f -name '*.gpg' > /dev/null | sed -r 's/^.*password-store\/(.*)\.gpg$/\1/g' | fzf | xargs pass -c"
# alias i3_fzf_pass='i3-msg -q "exec --no-startup-id $(fzf_pass)"'

function _grepex() {
    grep -rnE "$1" $(pwd)
}

bindkey '^y' autosuggest-accept
bindkey -s ^f "tmux-sessionizer\n"
