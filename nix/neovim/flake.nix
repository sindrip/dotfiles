{
  description = "Neovim";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
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
      packages.aarch64-darwin.default = wrapped-neovim;

      app.aarch64-darwin.default = wrapped-neovim;

      formatter.aarch64-darwin = pkgs.nixfmt-rfc-style;
    };
}
