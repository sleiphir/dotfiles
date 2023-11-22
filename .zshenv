path+=("$HOME/.config/scripts")

# Add .local/bin to PATH
path+=("$HOME/.local/bin")

# Add go to path
path+=("/usr/local/go/bin")

# Add NeoVim to PATH
path+=("/usr/local/nvim/bin")

export PATH

# Set vi mode cursor
export VI_MODE_SET_CURSOR=true

# No Esc delay
export KEYTIMEOUT=1

# Set JAVA_HOME
export JAVA_HOME=$HOME/.jdks/jdk-20.0.2

export GPG_TTY=$(tty)

