export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_RUNTIME_DIR="$TMPDIR"
export XDG_STATE_HOME="$HOME/.local/state"
export PATH="$XDG_BIN_HOME:$PATH"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# Disable macOS shell sessions
export SHELL_SESSIONS_DISABLE=1

. "$HOME/.cargo/env"
