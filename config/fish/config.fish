# Editor
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SUDO_EDITOR nvim

# Fish
set -g fish_greeting

# Shell integrations (interactive only)
if status is-interactive
    command -q mise && mise activate fish | source
    command -q zoxide && zoxide init fish | source
    command -q fzf && fzf --fish | source # Ctrl-T/R, Alt-C keybindings
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
