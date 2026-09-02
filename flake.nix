{
  description = "Lambdajon's website";

  nixConfig = {
    extra-substituters = [ "https://lambdajon.cachix.org" ];
    extra-trusted-public-keys = [
      "lambdajon.cachix.org-1:6+t9OJus42lomgVGzhZdGQH9JL14HWUDXxop2usvric="
    ];
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

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , flake-utils
    , git-hooks
    , treefmt-nix
    }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};

        hp = pkgs.haskell.packages.ghc912.override {
          overrides = _self: super: {
            brick = pkgs.haskell.lib.dontCheck (pkgs.haskell.lib.doJailbreak super.brick);
          };
        };

        website = pkgs.haskell.lib.justStaticExecutables
          (hp.callCabal2nix "website" ./. { });

        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.fourmolu.enable = true;
          programs.cabal-fmt.enable = true;
          programs.nixfmt.enable = true;
        };
      in
      {
        packages.default = website;

        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScript "run-website" ''
            export PATH="${pkgs.typescript}/bin:$PATH"
            exec ${website}/bin/website "$@"
          ''}";
        };

        devShells.default = hp.shellFor {
          packages = p: [ p.website ];
          buildInputs = with pkgs; [
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
            pkgs.haskellPackages.cabal-fmt
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
