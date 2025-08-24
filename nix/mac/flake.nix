{
  description = "Mac";

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
            pkgs.docker
            pkgs.colima
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
