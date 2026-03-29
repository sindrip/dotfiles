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
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export CP_HOME_DIR="$XDG_DATA_HOME/cocoapods"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GEM_HOME="$XDG_DATA_HOME/gem"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export TMUX_PLUGIN_MANAGER_PATH="$XDG_DATA_HOME/tmux/plugins"

# Disable macOS per-session shell history
export SHELL_SESSIONS_DISABLE=1
