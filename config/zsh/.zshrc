# History
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Completion
# fpath=(/Applications/OrbStack.app/Contents/Resources/completions/zsh(/N) $fpath)
autoload -Uz compinit
mkdir -p "$XDG_CACHE_HOME/zsh"
compinit -i -d "$XDG_CACHE_HOME/zsh/zcompdump-$(date +%Y%m%d)"

# Completion UX
setopt COMPLETE_IN_WORD ALWAYS_TO_END LIST_PACKED
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors 'di=1;34' 'ln=1;36' 'so=1;35' 'pi=33' 'ex=1;32' 'bd=1;33' 'cd=1;33' 'or=31' ${(s.:.)LS_COLORS}

# Navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Behavior
setopt NO_BEEP # No terminal bell
setopt NUMERIC_GLOB_SORT # Sort globs numerically (file2 before file10)

# Keybindings
bindkey -e
# ↑/↓ history search is bound in plugins.zsh (history-substring-search)

# Aliases
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -lh --icons=auto --git --group-directories-first'
alias la='eza -lah --icons=auto --git --group-directories-first'
alias tree='eza --tree --icons=auto'

alias -- -='cd -' # `-` jumps to the previous directory
alias vim='nvim'
alias df='df -h'

# Editor
export EDITOR=nvim
export VISUAL=nvim
export SUDO_EDITOR=nvim

# fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height=60% --layout=reverse --border=rounded'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}' --preview-window=right:60%:border-left"

# Shell integrations
(( $+commands[fzf] )) && source "$HOMEBREW_PREFIX/opt/fzf/shell/key-bindings.zsh"  # Ctrl-T/R/Alt-C only; Tab stays native
(( $+commands[mise] )) && eval "$(mise activate zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[starship] )) && eval "$(starship init zsh)"

# Plugins (sourced last so syntax highlighting wraps all prior ZLE widgets)
[[ -r "$ZDOTDIR/plugins.zsh" ]] && source "$ZDOTDIR/plugins.zsh"
