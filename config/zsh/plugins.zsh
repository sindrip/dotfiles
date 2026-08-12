# Zsh plugins, installed in the Nix `tools` profile and sourced here.
# Order matters (verified against each README): autosuggestions, then
# fast-syntax-highlighting, then history-substring-search last (after
# syntax highlighting).
_nix_zsh_plugins="$HOME/.nix-profile/share/zsh/plugins"
source "$_nix_zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$_nix_zsh_plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source "$_nix_zsh_plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
unset _nix_zsh_plugins

# history-substring-search: dedupe matches, drive from the arrow keys.
# Bind both normal (^[[A) and application-cursor (^[OA) escapes — the same
# key sends different bytes depending on the terminal's cursor-key mode, and
# tmux-256color reports the application-mode form (terminfo kcuu1=\EOA).
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
bindkey '^[[A' history-substring-search-up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OB' history-substring-search-down

# To revert to zero-dependency prefix-search, comment the two bindkey lines
# above and uncomment these:
# autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
# zle -N up-line-or-beginning-search
# zle -N down-line-or-beginning-search
# bindkey '^[[A' up-line-or-beginning-search
# bindkey '^[[B' down-line-or-beginning-search
