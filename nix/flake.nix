{
  description = "Nix home profile";

  # A flake in some other directory.
  # inputs.otherDir.url = "/home/alice/src/patchelf";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # Easily find versions to pin: https://lazamar.co.uk/nix-versions/
  # Pin to 0.33.5 until 0.33.6 is merged: https://github.com/NixOS/nixpkgs/issues/260411
  #inputs.tilt-pin-pkgs.url = "https://github.com/NixOS/nixpkgs/archive/e1ee359d16a1886f0771cc433a00827da98d861c.tar.gz";

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (nixpkgs.lib) optional;
        pkgs = import nixpkgs { inherit system; };
        wrapped-neovim = let
          neovim-extra = [
            pkgs.gcc
            pkgs.stylua
            pkgs.nixfmt
            pkgs.shellcheck
            pkgs.pgformatter
            pkgs.sqlfluff
          ];
        in pkgs.symlinkJoin {
          name = "nvim";
          paths = [ pkgs.neovim ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/nvim \
              --prefix PATH : ${pkgs.lib.makeBinPath neovim-extra}
          '';
        };
        #tilt-pkgs = import inputs.tilt-pin-pkgs { inherit system; };
      in {
        packages.default = pkgs.buildEnv {
          name = "Home";
          paths = [
            # Core
            pkgs.gnumake
            pkgs.protobuf
            pkgs.direnv
            pkgs.nix-direnv
            pkgs.tree
            pkgs.git
            pkgs.ripgrep
            pkgs.fd
            pkgs.jq
            pkgs.tmux
            pkgs.gh
            wrapped-neovim

            # Misc
            pkgs.iosevka
            pkgs.nerd-fonts.symbols-only
            # (pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })

            # Kubernetes
            pkgs.kubectl
            pkgs.kubelogin
            pkgs.kubernetes-helm
            pkgs.tilt
            pkgs.kind
            pkgs.ctlptl
            pkgs.kustomize
            pkgs.azure-cli
            pkgs.argocd

            # Languages
            pkgs.beam.packages.erlang_27.elixir_1_18
            pkgs.beam.interpreters.erlang_27
            pkgs.rebar3
            pkgs.rustup
            pkgs.nodejs

            # Scripts
            (pkgs.writeScriptBin "update-profile" ''
              #!${pkgs.stdenv.shell}
              nix profile upgrade --all
            '')
            (pkgs.writeScriptBin "dotfiles" ''
              #!${pkgs.stdenv.shell}
              git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
            '')
          ];
          pathsToLink = [ "/share" "/bin" ];
          extraOutputsToInstall = [ "man" "doc" ];
        };

        packages.bootstrap = pkgs.writeShellApplication {
          name = "bootstrap";
          runtimeInputs = [ pkgs.git ];
          text = ''
            DOT_DIR=$HOME/.dotfiles
            echo "Initializing dotfiles repo: $DOT_DIR" && \
            git clone --bare https://github.com/sindrip/dotfiles.git "$DOT_DIR" && \
            git --git-dir "$DOT_DIR" --work-tree="$HOME" checkout && \
            cd "$HOME"/nix && \
            nix profile install
          '';
        };

        #formatter = pkgs.nixfmt;
      });
}
