# Darwin Dotfiles

Install RayCast and set it as the default launcher.
- [] Disable Spotlight shortcut (Cmd + Space) in settings (or use the command below)
- [] Change RayCast shortcut to Cmd + Space in RayCast settings
- [] Add favorite apps to RayCast for quick access

To programatically disable the Spotlight shortcut (Cmd + Space), and Finder Search (Cmd + Option + Space), you can run the following command in the terminal:
```sh
$ defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"
$ defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "<dict><key>enabled</key><false/></dict>"
```

```sh
# Set the GLobe key to do nothing
$ defaults write com.apple.HIToolbox AppleFnUsageType -int 0
```

And to avoid having to login and out for the changes to take effect, you can run this command to activate the new settings immediately:
```sh
$ /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
```

Install AeroSpace to manage window snapping and layouts:
```sh
$ brew install --cask nikitabobko/tap/aerospace
```
