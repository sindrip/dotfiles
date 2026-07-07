# XDG Base Directory
set -gx XDG_BIN_HOME "$HOME/.local/bin"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"
set -gx XDG_RUNTIME_DIR "$TMPDIR"

# Zsh
set -gx ZDOTDIR "$XDG_CONFIG_HOME/zsh"
set -gx HISTFILE "$XDG_STATE_HOME/zsh/history"

# XDG compliance for tools that don't respect it by default
set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"
set -gx GOPATH "$XDG_DATA_HOME/go"
set -gx LESSHISTFILE "$XDG_STATE_HOME/less/history"
set -gx NODE_REPL_HISTORY "$XDG_DATA_HOME/node_repl_history"
set -gx RUSTUP_HOME "$XDG_DATA_HOME/rustup"

# Disable macOS per-session shell history
set -gx SHELL_SESSIONS_DISABLE 1

# Vendor completions from homebrew- and nix-installed tools (nix's fish only
# scans its own store path and XDG_DATA_DIRS, which macOS leaves unset)
set -a fish_complete_path \
    /opt/homebrew/share/fish/vendor_completions.d \
    "$HOME/.nix-profile/share/fish/vendor_completions.d"
