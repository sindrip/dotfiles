# Dotfiles

Personal dotfiles for macOS.

```sh
./install.sh
mise bootstrap
```

`install.sh` runs `brew bundle`, symlinks `config/` to `~/.config/`, and `bin/` to `~/.local/bin/`.

`mise bootstrap` applies macOS defaults (keyboard, dock, trackpad, autocorrect, hotkeys).

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
