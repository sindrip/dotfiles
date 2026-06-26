# Editor
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SUDO_EDITOR nvim

# fzf
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git --strip-cwd-prefix'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_DEFAULT_OPTS '--height=60% --layout=reverse --border=rounded'
set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:500 {}' --preview-window=right:60%:border-left"

# Shell integrations (interactive only)
if status is-interactive
    command -q mise && mise activate fish | source
    command -q zoxide && zoxide init fish | source
    command -q fzf && fzf --fish | source # Ctrl-T/R, Alt-C keybindings
    command -q vp && source "$HOME/.vite-plus/env.fish" # node/npm/npx shims, vp wrapper + completion (https://viteplus.dev)
    command -q starship && starship init fish | source

    # Aliases
    alias ls 'eza --icons=auto --group-directories-first'
    alias ll 'eza -lh --icons=auto --git --group-directories-first'
    alias la 'eza -lah --icons=auto --git --group-directories-first'
    alias tree 'eza --tree --icons=auto'
    alias vim nvim
    alias df 'df -h'
    abbr -a --regex '^-$' -- dash 'cd -' # `-` jumps to the previous directory
end
