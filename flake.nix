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
          pkgs = nixpkgs.legacyPackages.${system};
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
              bat
              eza
              fd
              fish
              fzf
              jq
              ripgrep
              starship
              tree-sitter
              zoxide
              zsh-autosuggestions
              zsh-fast-syntax-highlighting
              zsh-history-substring-search

              # General development tools
              difftastic
              gh
              (google-cloud-sdk.withExtraComponents [
                google-cloud-sdk.components.gke-gcloud-auth-plugin
              ])
              lazydocker
              lazygit
              mise
              # client only: the daemon stays on the root profile's nix. Needed
              # until nix-fallback-paths ships a build linking libgit2 >= 1.9.4,
              # without which flake commands cannot open a relative worktree
              nixVersions.latest
              ruff
              rustup
              sesh
              typescript-go
              ty
              uv
              xdg-ninja

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
