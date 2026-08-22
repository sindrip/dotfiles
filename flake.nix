{
  description = "sindrip's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # No `follows` on purpose: overriding the overlay's nixpkgs would change
    # the derivation hash and miss its binary cache, forcing source builds.
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # tpm and tmux plugins, pinned here instead of cloned by tpm at runtime.
    # Inputs are a flat namespace (their second level is the input-spec
    # schema: url/flake/follows/...), so the grouping is in the name only.
    "tmux.tpm" = {
      url = "github:tmux-plugins/tpm";
      flake = false;
    };
    "tmux.catppuccin" = {
      url = "github:catppuccin/tmux";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      neovim-nightly-overlay,
      ...
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "copilot-language-server";
          };
          # dir names must match the repo basename of the @plugin lines in
          # tmux.conf: that is how tpm looks plugins up
          tmux-plugins = pkgs.buildEnv {
            name = "tmux-plugins";
            paths = [
              (pkgs.tmuxPlugins.mkTmuxPlugin {
                pluginName = "tpm";
                rtpFilePath = "tpm";
                version = inputs."tmux.tpm".shortRev;
                src = inputs."tmux.tpm";
              })
              (pkgs.tmuxPlugins.mkTmuxPlugin {
                pluginName = "tmux"; # catppuccin/tmux
                rtpFilePath = "catppuccin.tmux";
                version = inputs."tmux.catppuccin".shortRev;
                src = inputs."tmux.catppuccin";
              })
            ];
          };
          # pinned so the compiler and clangd share a frontend
          llvm22 = pkgs.llvmPackages_22;
          # only the C driver is linked out: the wrapper's bin also ships
          # clang++/cc/ld/as/ar/nm, which would shadow the Xcode toolchain
          # for every other build on the machine.
          # the unwrapped driver comes along for cross checks: the wrapper
          # injects macOS flags and libSystem headers even under a linux
          # --target, which -Werror catches and -Wno-... would only hide.
          llvm22-clang = pkgs.runCommand "clang-bin" { } ''
            mkdir -p $out/bin
            ln -s ${llvm22.clang}/bin/clang $out/bin/clang
            ln -s ${llvm22.clang-unwrapped}/bin/clang $out/bin/clang-unwrapped
          '';
        in
        rec {
          neovim = neovim-nightly-overlay.packages.${system}.default;
          default = neovim;

          # tmux wrapped so tpm finds itself and the pinned plugins, and so
          # new panes run the flake-pinned fish (tmux default-shell = $SHELL)
          tmux = pkgs.symlinkJoin {
            name = "tmux";
            paths = [ pkgs.tmux ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/tmux \
                --set TMUX_PLUGIN_MANAGER_PATH ${tmux-plugins}/share/tmux-plugins \
                --set SHELL ${pkgs.fish}/bin/fish
            '';
          };

          tools = pkgs.buildEnv {
            name = "cli-tools";
            paths = with pkgs; [
              # Shell and terminal tools
              fish
              sesh
              starship
              zoxide
              zsh-autosuggestions
              zsh-fast-syntax-highlighting
              zsh-history-substring-search

              # CLI utilities
              bat
              eza
              fd
              fzf
              jq
              ripgrep
              xdg-ninja

              # Git
              difftastic
              gh
              lazygit

              # Editor tools
              biome
              llvm22-clang
              llvm22.clang-tools
              copilot-language-server
              gopls
              lua-language-server
              prettier
              shfmt
              stylua
              tree-sitter
              typescript-go

              # Toolchain managers
              mise
              # Newer client for relative-worktree support; daemon stays system-managed.
              nixVersions.latest
              rustup

              # Python tools
              ruff
              ty
              uv

              # Cloud and containers
              (google-cloud-sdk.withExtraComponents [
                google-cloud-sdk.components.gke-gcloud-auth-plugin
              ])
              lazydocker

              # Kubernetes tools
              crossplane-cli
              flux9s
              fluxcd
              fluxcd-operator
              k9s
              kubectx
              kubernetes-helm
            ];
          };
        }
      );
    };
}
