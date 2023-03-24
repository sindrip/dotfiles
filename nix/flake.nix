{
  description = "Nix home profile";

  # A flake in some other directory.
  # inputs.otherDir.url = "/home/alice/src/patchelf";

  # The master branch of the NixOS/nixpkgs repository on GitHub.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
	inherit (nixpkgs.lib) optional;
	pkgs = import nixpkgs { inherit system; };
      in {
	packages.default = pkgs.buildEnv {
	  name = "Home";
	  paths = [
	    #pkgs.glibcLocales
	    pkgs.ripgrep
	    pkgs.fd
	    pkgs.neovim

	    pkgs.kubectl
	    pkgs.kubelogin
	    pkgs.kubernetes-helm
	    pkgs.tilt
	    pkgs.kind
	    pkgs.ctlptl
	    pkgs.kustomize

	    pkgs.beam.packages.erlangR25.elixir_1_14

	    (pkgs.writeScriptBin "upgrade-profile" ''
	      #!${pkgs.stdenv.shell}
	      nix profile upgrade '.*'
	    '')
	  ];
	  pathsToLink = [ "/share" "/bin" ];
	  extraOutputsToInstall = [ "man" "doc" ];
	};
      }
    );
}
