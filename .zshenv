path+=("$HOME/.config/scripts")
path+=("$HOME/.local/bin")
path+=("$HOME/go/bin/")

export PATH

# Set zsh compdump location
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export FZF_BASE=/usr/bin/fzf

export DISABLE_FZF_AUTO_COMPLETION="false"

export ZSH="$HOME/.oh-my-zsh"

# Set vi mode cursor
export VI_MODE_SET_CURSOR=true

# Set .config folder location
export XDG_CONFIG_HOME="$HOME/.config"

# No Esc delay
export KEYTIMEOUT=1

export GPG_TTY=$(tty)

# Export Anthropic API Key for Avante.nvim
export ANTHROPIC_API_KEY=$(cat ~/.anthropic_api_key)
export OPENAI_API_KEY=$(cat ~/.openai_api_key)
export DEEPSEEK_API_KEY=$(cat ~/.deepseek_api_key)
export OPENROUTER_API_KEY=$(cat ~/.openrouter_api_key)
export OPENROUTER_PROVISION_API_KEY=$(cat ~/.openrouter_provision_api_key)

# Man pager
export MANPAGER="nvim +Man!"

# FZF colors
export FZF_DEFAULT_OPTS='--color=bw'
