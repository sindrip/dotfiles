# Dotfiles

Install [nix](https://nixos.org/download.html)

`nix shell --extra-experimental-features nix-command --extra-experimental-features flakes nixpkgs#git`

`git clone --bare https://github.com/sindrip/dotfiles.git $HOME/.dotfiles`

`git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout`

`cd nix && nix profile install`

`nix run github:sindrip/dotfiles?dir=nix#bootstrap`
