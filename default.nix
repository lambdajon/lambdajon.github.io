{ dream2nix, config, lib, pkgs, ... }: {
  imports = [ dream2nix.modules.dream2nix.WIP-haskell-cabal ];

  name = "website";
  version = "0.1.0.0";

  deps = { nixpkgs, ... }: {
    haskell-compiler = nixpkgs.haskell.compiler.ghc912;
    inherit (nixpkgs) bzip2 libzip pkg-config typescript zlib;
  };

  mkDerivation.src = lib.cleanSourceWith {
    src = lib.cleanSource ./.;
    filter = name: type:
      let baseName = baseNameOf (toString name);
      in !(lib.hasSuffix ".nix" baseName);
  };

  mkDerivation.buildInputs =
    with config.deps; [ zlib bzip2 bzip2.dev libzip ];

  mkDerivation.nativeBuildInputs = [ config.deps.pkg-config pkgs.makeWrapper ];

  # Ensure allow-newer is applied after dream2nix rewrites cabal.project
  mkDerivation.preBuild = ''
    echo "allow-newer: all" >> cabal.project
    echo "constraints: transformers-compat == 0.7.2" >> cabal.project
  '';

  mkDerivation.postInstall = ''
    wrapProgram $out/bin/website \
      --prefix PATH : ${config.deps.typescript}/bin
  '';
}
