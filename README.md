# Dotfiles

Personal dotfiles for macOS.

```sh
./install.sh
```

`install.sh` symlinks configs to `~/.config/`, scripts to `~/.local/bin/`, runs `brew bundle`, and calls `mise bootstrap` which applies macOS defaults (keyboard, dock, trackpad, autocorrect, hotkeys, Ghostty keybinding).

## Post-install

### npm

Keep npm XDG-compliant:

```sh
mkdir -p ~/.config/npm
cat > ~/.config/npm/npmrc << 'EOF'
prefix=${XDG_DATA_HOME}/npm
cache=${XDG_CACHE_HOME}/npm
init-module=${XDG_CONFIG_HOME}/npm/config/npm-init.js
EOF
```
