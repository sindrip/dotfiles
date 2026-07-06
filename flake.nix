{
  description = "sindrip's dotfiles";

  # Only honored for users the nix daemon trusts (see README).
  # sindrip.cachix.org carries the aarch64-darwin neovim builds our CI pushes;
  # nix-community covers linux.
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://sindrip.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "sindrip.cachix.org-1:tni1LcPdMGxgmv3ZseA3ULu3oMwR5iz1/0p9ibhBPHE="
    ];
  };

  inputs = {
    # No `follows` on purpose: overriding the overlay's nixpkgs would change
    # the derivation hash and miss its binary cache, forcing source builds.
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, neovim-nightly-overlay, ... }:
    let
      forAllSystems = f: builtins.listToAttrs (map
        (system: { name = system; value = f system; })
        [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ]);
    in
    {
      packages = forAllSystems (system: rec {
        neovim = neovim-nightly-overlay.packages.${system}.default;
        default = neovim;
      });
    };
}
