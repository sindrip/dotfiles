eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Raise macOS's low per-process file descriptor limit for editors and watchers.
ulimit -Sn 8192

path=(
  $HOME/.local/bin(N)
  $HOME/.nix-profile/bin(N)
  $CARGO_HOME/bin(N)
  $HOME/.orbstack/bin(N)
  $path
)

fpath=(
  $HOME/.nix-profile/share/zsh/site-functions(N)
  $fpath
)

typeset -TUx XDG_DATA_DIRS xdg_data_dirs
xdg_data_dirs=(
  $HOME/.nix-profile/share
  $HOMEBREW_PREFIX/share
  $xdg_data_dirs
  /usr/local/share
  /usr/share
)
