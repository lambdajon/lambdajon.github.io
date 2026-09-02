{
  description = "Lambdajon's website";

  nixConfig = {
    extra-substituters = [
      "https://cache.iog.io"
      "https://lambdajon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "lambdajon.cachix.org-1:6+t9OJus42lomgVGzhZdGQH9JL14HWUDXxop2usvric="
    ];
  };

  inputs = {
    haskell-nix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskell-nix/nixpkgs-unstable";
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

  outputs =
    { self
    , nixpkgs
    , haskell-nix
    , flake-utils
    , git-hooks
    , treefmt-nix
    }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ haskell-nix.overlay ];
          inherit (haskell-nix) config;
        };

        project = pkgs.haskell-nix.cabalProject' {
          src = ./.;
          compiler-nix-name = "ghc9122";
          modules = [
            {
              doHaddock = false;
              doCheck = false;
            }
          ];
        };

        website-exe = project.hsPkgs.website.components.exes.website;

        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.fourmolu.enable = true;
          programs.cabal-fmt.enable = true;
          programs.nixfmt.enable = true;
        };
      in
      {
        packages.default = website-exe;

        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScript "run-website" ''
            export PATH="${pkgs.typescript}/bin:$PATH"
            exec ${website-exe}/bin/website "$@"
          ''}";
        };

        devShells.default = project.shellFor {
          tools = {
            cabal = "latest";
            haskell-language-server = "latest";
            fourmolu = "latest";
            hlint = "latest";
          };
          buildInputs = with pkgs; [
            pkg-config
            zlib
            zlib.dev
            bzip2
            bzip2.dev
            libzip
            typescript
            just
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

        checks = {
          pre-commit = git-hooks.lib.${system}.run {
            src = ./.;
            hooks.treefmt = {
              enable = true;
              package = treefmtEval.config.build.wrapper;
            };
          };
        };
      });
}
