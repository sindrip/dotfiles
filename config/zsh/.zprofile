eval "$(/opt/homebrew/bin/brew shellenv zsh)"

path=("$HOME/.local/bin" "$HOME/.bun/bin" "$CARGO_HOME/bin" "$HOMEBREW_PREFIX/share/google-cloud-sdk/bin" $path)
