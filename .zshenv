path+=("$HOME/.config/scripts")
path+=("$HOME/.local/bin")

# asdf
path+=("$HOME/.asdf/shims")

# Go
path+=("$HOME/.asdf/installs/golang/$(go version | awk '{print $3}' | sed 's/[a-z]*//')/packages/bin")

# Rust
path+=("$HOME/.asdf/installs/rust/$(cargo version | awk '{print $2}')/bin")

# Neovim
path+=("/opt/nvim-linux64/bin")

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

# No Esc delay
export KEYTIMEOUT=1

export GPG_TTY=$(tty)

# System wide dark theme
export GTK_THEME=Adwaita:dark
export GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc
export QT_STYLE_OVERRIDE=Adwaita-Dark
