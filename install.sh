#!/usr/bin/env sh
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

info() { printf '\033[32mOK:\033[0m %s\n' "$1"; }
warn() { printf '\033[33mWARN:\033[0m %s\n' "$1"; }
header() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }

link() {
  src="$1"
  dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    warn "$dest already exists (not a symlink), skipping"
    return
  fi
  ln -sf "$src" "$dest"
  info "$dest -> $src"
}

header "Repo state"
untracked=$(git -C "$DOTFILES" ls-files --others --exclude-standard)
if [ -n "$untracked" ]; then
  warn "untracked files in dotfiles repo (won't be linked, won't survive a re-clone):"
  printf '%s\n' "$untracked" | while read -r f; do warn "  $f"; done
else
  info "no untracked files"
fi

header "Dotfiles"
(
  cd "$DOTFILES/config"
  # Link only tracked files
  git ls-files | while read -r f; do
    mkdir -p "$HOME/.config/$(dirname "$f")"
    link "$DOTFILES/config/$f" "$HOME/.config/$f"
  done
)

header "Non-XDG dotfiles"
# zshenv (must live in ~/ to bootstrap ZDOTDIR)
link "$DOTFILES/zshenv" "$HOME/.zshenv"
# hushlogin (suppress "Last login" message)
link "$DOTFILES/hushlogin" "$HOME/.hushlogin"

header "Scripts"
mkdir -p "$HOME/.local/bin"
for f in "$DOTFILES/bin/"*; do
  link "$f" "$HOME/.local/bin/$(basename "$f")"
done

header "Claude skills"
# Copied, not symlinked: Claude Code's skill discovery doesn't resolve a
# symlinked skill directory, so a symlink would silently fail to register.
# The repo is the source of truth; this overwrites on every run.
mkdir -p "$HOME/.claude/skills"
for skill in "$DOTFILES/claude/skills/"*/; do
  name="$(basename "$skill")"
  dest="$HOME/.claude/skills/$name"
  rm -rf "$dest"
  cp -R "${skill%/}" "$dest"
  info "skill $name -> $dest"
done

header "Directories"
# ensure directories exist for paths introduced by zshenv
# sources zshenv in a clean shell (env -i) and diffs the environment
# before and after to find only the variables zshenv adds
ensure_dirs() {
  # shellcheck disable=SC2016
  env -i HOME="$HOME" ZSHENV="$DOTFILES/zshenv" sh -c '
    before=$(env | grep -v "^_=")
    . "$ZSHENV"
    env | grep -v "^_=" | grep -vxF "$before"
  ' | while IFS='=' read -r name value; do
    case "$value" in
    /*)
      case "$name" in
      *FILE | *HISTORY | *USERCONFIG) dir="$(dirname "$value")" ;;
      *) dir="$value" ;;
      esac
      mkdir -p "$dir"
      info "ensured $dir"
      ;;
    esac
  done
}
ensure_dirs

header "Applications"
mkdir -p "$HOME/Applications"
for app in "$DOTFILES/apps/"*.app; do
  [ -e "$app" ] || continue
  dest="$HOME/Applications/$(basename "$app")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    warn "$dest already exists (not a symlink), skipping"
  else
    ln -sfn "$app" "$dest"
    info "$dest -> $app"
  fi
done

header "Packages"
brew bundle --verbose --file="$DOTFILES/Brewfile"

header "Nix"
nix registry add dotfiles "$DOTFILES"
info "registry: dotfiles -> $DOTFILES"
nix_profile_list="$(nix profile list)"
if echo "$nix_profile_list" | grep -q neovim; then
  nix profile upgrade neovim
else
  nix profile add dotfiles#neovim
fi
info "neovim nightly via nix profile"

header "GitHub extensions"
gh extension install dlvhdr/gh-dash 2>/dev/null || gh extension upgrade dlvhdr/gh-dash
gh extension install github/gh-stack 2>/dev/null || gh extension upgrade github/gh-stack

header "macOS defaults"
"$DOTFILES/bin/macos-defaults"

header "Mise"
mise trust "$HOME/.config/mise/config.toml"
mise upgrade

header "Touch ID sudo"
sudo_local="/etc/pam.d/sudo_local"
if [ ! -f "$sudo_local" ]; then
  : | sudo tee "$sudo_local" >/dev/null
fi
if ! grep -q pam_reattach "$sudo_local"; then
  printf 'auth       optional       /opt/homebrew/lib/pam/pam_reattach.so\n' | sudo tee -a "$sudo_local" >/dev/null
  info "added pam_reattach to $sudo_local"
fi
if ! grep -q pam_tid "$sudo_local"; then
  printf 'auth       sufficient     pam_tid.so\n' | sudo tee -a "$sudo_local" >/dev/null
  info "added pam_tid to $sudo_local"
fi
