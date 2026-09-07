# Discover package-supplied completions in login and non-login interactive shells.
typeset -U fpath
fpath=(
  "$HOME/.nix-profile/share/zsh/site-functions"(N/)
  "${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh/site-functions"(N/)
  /Applications/OrbStack.app/Contents/Resources/completions/zsh(N/)
  $fpath
)

zmodload zsh/complist
autoload -Uz compinit
mkdir -p "$XDG_CACHE_HOME/zsh"
# Let compinit audit providers and refresh its dump when completion counts change.
compinit -i -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
# Cache completion data for providers that support zsh's caching helpers.
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# Prefix matching first, then substring matching; both ignore case.
setopt COMPLETE_IN_WORD ALWAYS_TO_END LIST_PACKED AUTO_LIST AUTO_MENU
# First Tab completes/lists; a second Tab enters menu selection.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*' list-colors 'di=1;34' 'ln=1;36' 'so=1;35' 'pi=33' 'ex=1;32' 'bd=1;33' 'cd=1;33' 'or=31' ${(s.:.)LS_COLORS}

# Menu-local bindings navigate candidates independently of normal line editing.
bindkey -M menuselect '^N' menu-complete
bindkey -M menuselect '^P' reverse-menu-complete
bindkey -M menuselect '^I' menu-complete
bindkey -M menuselect '^[[Z' reverse-menu-complete
bindkey -M menuselect '^M' accept-line
bindkey -M menuselect '^[' send-break
bindkey -M menuselect '^[[A' up-line-or-history
bindkey -M menuselect '^[OA' up-line-or-history
bindkey -M menuselect '^[[B' down-line-or-history
bindkey -M menuselect '^[OB' down-line-or-history
bindkey -M menuselect '^[[C' forward-char
bindkey -M menuselect '^[OC' forward-char
bindkey -M menuselect '^[[D' backward-char
bindkey -M menuselect '^[OD' backward-char

# Keep the list while completing; clear it on other line-editor actions.
# Remember completion widgets before plugins wrap them as ordinary widgets.
typeset -ga _completion_widgets=( ${(k)widgets[(R)completion:*]} )
_clear_completion_list() {
  (( ${_completion_widgets[(Ie)$LASTWIDGET]} )) || zle -R -c
}
autoload -Uz add-zle-hook-widget
add-zle-hook-widget line-pre-redraw _clear_completion_list
