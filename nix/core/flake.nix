{
  description = "Core tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.buildEnv {
          name = "Core";
          paths = [
            pkgs.git
            pkgs.direnv
            pkgs.nix-direnv
            pkgs.eza
            pkgs.tmux

            pkgs.beam.packages.erlang_27.elixir_1_18
            pkgs.rustup
          ];
          pathsToLink = [
            "/share"
            "/bin"
          ];
          extraOutputsToInstall = [
            "man"
            "doc"
          ];
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
