{
  description = "sindrip's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # No `follows` on purpose: overriding the overlay's nixpkgs would change
    # the derivation hash and miss its binary cache, forcing source builds.
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, neovim-nightly-overlay, ... }:
    let
      forAllSystems = f: builtins.listToAttrs (map
        (system: { name = system; value = f system; })
        [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ]);
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in rec {
          neovim = neovim-nightly-overlay.packages.${system}.default;
          default = neovim;

          tools = pkgs.buildEnv {
            name = "cli-tools";
            paths = with pkgs; [
              bat
              eza
              fd
              tree-sitter
            ];
          };
        });
    };
}
