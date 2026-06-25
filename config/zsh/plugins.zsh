# Zsh plugins, installed via Homebrew (see Brewfile) and sourced here.
# Order matters (verified against each README): autosuggestions, then
# fast-syntax-highlighting, then history-substring-search last (after
# syntax highlighting).
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh

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
