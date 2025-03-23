{
  description = "An environment for haskell development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self , nixpkgs ,... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };

    # add other packages here
    ghc = pkgs.haskellPackages.ghcWithPackages (p: [ 
      p.hscurses p.random
    ]);
    haskellDev = with pkgs; [
      haskellPackages.hscurses
      ghc
      gnumake
      ncurses
    ];

  in {
    devShells."${system}".default = pkgs.mkShell {
      packages = [
        haskellDev
      ];

      buildInputs = [
        haskellDev
      ];
    };

    packages.${system}.default = let 
      excecutable = "gameOfLife";

    in pkgs.stdenv.mkDerivation {
      name = excecutable;
      description = "A minimalistic haskell dev environment";
      src = ./.; 
      nativeBuildInputs = [
        haskellDev
      ];

      buildPhase = ''
        make -j3
      '';
      
      installPhase = ''
        mkdir -p $out/bin
        install -t $out/bin build/${excecutable}
      '';
    };
  };
}
