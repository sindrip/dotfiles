eval "$(/opt/homebrew/bin/brew shellenv zsh)"

path=(
  $HOME/.local/bin(N)
  $HOME/.bun/bin(N)
  $CARGO_HOME/bin(N)
  $HOMEBREW_PREFIX/share/google-cloud-sdk/bin(N)
  $HOME/.orbstack/bin(N)
  $path
)

typeset -TUx XDG_DATA_DIRS xdg_data_dirs
xdg_data_dirs=(
  $HOMEBREW_PREFIX/share
  $xdg_data_dirs
  /usr/local/share
  /usr/share
)
