# Dotfiles

Personal dotfiles for macOS.

```sh
./install.sh
```

Runs `brew bundle`, symlinks `config/` to `~/.config/`, and `bin/` to `~/.local/bin/`.

## Post-install

### macOS keyboard

Disable Ctrl+Space for input source switching in System Settings > Keyboard > Keyboard Shortcuts > Input Sources.

### Docker (Colima)

Homebrew's docker plugins install to a non-standard path. Tell Docker where to find them:

```sh
mkdir -p ~/.config/docker
echo '{"cliPluginsExtraDirs":["/opt/homebrew/lib/docker/cli-plugins"]}' > ~/.config/docker/config.json
```

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

