{
  description = "Nix home profile";

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

            # Misc
            pkgs.iosevka
            pkgs.nerd-fonts.symbols-only

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
