# XDG Base Directory
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_RUNTIME_DIR="$TMPDIR"

# Zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# XDG compliance for tools that don't respect it by default
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export TMUX_PLUGIN_MANAGER_PATH="$XDG_DATA_HOME/tmux/plugins"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

# Disable macOS per-session shell history
export SHELL_SESSIONS_DISABLE=1
