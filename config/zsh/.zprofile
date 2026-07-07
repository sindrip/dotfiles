eval "$(/opt/homebrew/bin/brew shellenv zsh)"

path=(
  $HOME/.local/bin(N)
  $HOME/.bun/bin(N)
  $CARGO_HOME/bin(N)
  $HOMEBREW_PREFIX/share/google-cloud-sdk/bin(N)
  $HOME/.orbstack/bin(N)
  $path
)

export XDG_DATA_DIRS="$HOMEBREW_PREFIX/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
