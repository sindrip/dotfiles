# History
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY # Record timestamp of command in history file
setopt HIST_EXPIRE_DUPS_FIRST # Delete duplicates first when history file size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS # Don't record duplicate commands in history list
setopt HIST_SAVE_NO_DUPS # Don't save duplicate commands to history file
setopt HIST_IGNORE_SPACE # Ignore commands that start with space (useful for sensitive commands)
setopt HIST_VERIFY # Show command with history expansion before running it
setopt SHARE_HISTORY # Share command history across all terminal sessions

# Completion
autoload -U compinit
compinit

# Navigation
setopt autocd
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Keybindings
bindkey -e
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Aliases
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lAh'

# Editor
export EDITOR=nvim
export VISUAL=nvim
export SUDO_EDITOR=nvim
# export MANPAGER="nvim +Man!" # Use nvim to display man pages with syntax highlighting

# Tools
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,underline'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'

source <(fzf --zsh)
source <(mise activate zsh)
source <(starship init zsh)
