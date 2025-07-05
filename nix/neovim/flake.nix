{
  description = "Neovim";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        # let
        # pkgs = import nixpkgs { system = "aarch64-darwin"; };
        wrapped-neovim =
          let
            neovim-extra = [
              pkgs.git
              pkgs.ripgrep
              pkgs.fd

              # Formatters
              pkgs.stylua
              pkgs.nixfmt-rfc-style

              # Language servers
              pkgs.shellcheck
              pkgs.lua-language-server
              pkgs.nixd

              pkgs.next-ls
              pkgs.lexical
              pkgs.elixir-ls
            ];
          in
          pkgs.symlinkJoin {
            name = "nvim";
            paths = [
              pkgs.neovim-unwrapped
            ];
            nativeBuildInputs = [
              pkgs.makeWrapper
            ];
            postBuild = ''
              wrapProgram $out/bin/nvim \
                --prefix PATH : ${pkgs.lib.makeBinPath neovim-extra}
            '';
          };
      in
      {
        packages.default = wrapped-neovim;

        app.default = wrapped-neovim;

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
