{
  description = "Core tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
    in
    {
      packages.aarch64-darwin.default = pkgs.buildEnv {
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

      formatter.aarch64-darwin = pkgs.nixfmt-rfc-style;
    };
}
