{
  description = "Lambdajon's website";

  nixConfig = {
    extra-substituters = [ "https://lambdajon.cachix.org" ];
    extra-trusted-public-keys =
      [ "lambdajon.cachix.org-1:6+t9OJus42lomgVGzhZdGQH9JL14HWUDXxop2usvric=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, treefmt-nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};

        hl = pkgs.haskell.lib;

        hp = pkgs.haskell.packages.ghc912.override {
          overrides = self: super: {
            brick = hl.dontCheck (hl.doJailbreak super.brick);
            xml-conduit = hl.dontCheck (hl.doJailbreak super.xml-conduit);
            unicode-data = hl.dontCheck super.unicode-data;
            unicode-transforms = hl.dontCheck super.unicode-transforms;
            unicode-collation = hl.dontCheck super.unicode-collation;
            pandoc = hl.dontCheck super.pandoc;
            commonmark = hl.dontCheck super.commonmark;
            commonmark-extensions = hl.dontCheck super.commonmark-extensions;
            commonmark-pandoc = hl.dontCheck super.commonmark-pandoc;
            website = self.callCabal2nix "website" ./. { };
          };
        };

        website = hp.website;

        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.fourmolu.enable = true;
          programs.fourmolu.package =
            pkgsUnstable.haskell.packages.ghc912.fourmolu;
          programs.cabal-fmt.enable = true;
          programs.nixfmt.enable = true;
        };
      in {
        packages.default = website;

        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScript "run-website" ''
            export PATH="${pkgs.typescript}/bin:$PATH"
            exec ${website}/bin/website "$@"
          ''}";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            hp.ghc
            cabal-install
            pkg-config
            zlib
            zlib.dev
            bzip2
            bzip2.dev
            libzip
            typescript
            just
            pkgsUnstable.haskell.packages.ghc912.fourmolu
            hp.haskell-language-server
            hp.hlint
            haskellPackages.cabal-fmt
            treefmtEval.config.build.wrapper
          ];
          shellHook = ''
            echo "Welcome to website dev shell"
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.libzip}/lib
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.bzip2}/lib
            export LIBRARY_PATH=$LIBRARY_PATH:${pkgs.bzip2}/lib
            export NIX_LDFLAGS="$NIX_LDFLAGS -L${pkgs.bzip2}/lib"
          '';
        };

        formatter = treefmtEval.config.build.wrapper;
      });
}
