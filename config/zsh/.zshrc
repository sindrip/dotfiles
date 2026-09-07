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
source "$ZDOTDIR/completions.zsh"

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
# Native history search: match the typed prefix; move within multiline input.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search

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
if (( $+commands[fzf] )); then
  _fzf_share="${commands[fzf]:A:h:h}/share/fzf"
  [[ -r "$_fzf_share/key-bindings.zsh" ]] && source "$_fzf_share/key-bindings.zsh"  # Ctrl-T/R/Alt-C only; Tab stays native
  unset _fzf_share
fi
(( $+commands[mise] )) && eval "$(mise activate zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[starship] )) && eval "$(starship init zsh)"


# Load approved .envrc files on directory changes and before each prompt.
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
