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

  outputs = inputs@{ self, nixpkgs, neovim-nightly-overlay, ... }:
    let
      forAllSystems = f: builtins.listToAttrs (map
        (system: { name = system; value = f system; })
        [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ]);
    in
    {
      packages = forAllSystems (system:
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
        in rec {
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
              bat
              eza
              fd
              fish
              starship
              tree-sitter
            ];
          };
        });
    };
}
