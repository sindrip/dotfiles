{
  description = "Nix home profile";

  # A flake in some other directory.
  # inputs.otherDir.url = "/home/alice/src/patchelf";

  # The master branch of the NixOS/nixpkgs repository on GitHub.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (nixpkgs.lib) optional;
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.buildEnv {
          name = "Home";
          paths = [
            pkgs.git
            pkgs.ripgrep
            pkgs.fd
            pkgs.neovim
            pkgs.tmux

            pkgs.kubectl
            pkgs.kubelogin
            pkgs.kubernetes-helm
            pkgs.tilt
            pkgs.kind
            pkgs.ctlptl
            pkgs.kustomize

            pkgs.beam.packages.erlangR26.elixir_1_15

            (pkgs.writeScriptBin "update-profile" ''
              #!${pkgs.stdenv.shell}
              nix profile upgrade '.*'
            '')
            (pkgs.writeScriptBin "dotfiles" ''
              #!${pkgs.stdenv.shell}
              git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
            '')
          ];
          pathsToLink = [ "/share" "/bin" ];
          extraOutputsToInstall = [ "man" "doc" ];
        };

        packages.bootstrap = pkgs.writeScriptBin "bootstrap" ''
          #!${pkgs.stdenv.shell}
          DOT_DIR=$HOME/.dotfiles
          nix shell nixpkgs#git \
            --extra-experimental-features nix-command \
            --extra-experimental-features flakes \
            --command \
            echo "Initializing dotfiles repo: $DOT_DIR" && \
            git clone --bare https://github.com/sindrip/dotfiles.git $DOT_DIR && \
            git --git-dir $DOT_DIR --work-tree=$HOME checkout && \
            cd $HOME/nix && \
            nix profile install
        '';
      });
}
