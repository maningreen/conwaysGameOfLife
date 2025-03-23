# Conway's Game Of Life

I recently began the delve into functional programming, primarily haskell, doing this i wanted to make conway's game of life.
Every time to run the game it randomly generates a grid and runs through that.

## Building


### With Make

#### Dependancies

- ghc
- hscurses
- gnumake
- haskell random

#### Building and Running

`make` should spit an excecutable called out at build/game
excecute it with `./build/game` (or if you're weird `build/game`)

### With Nix Flakes

#### Enable Flakes

##### NixOS

In your `configuration.nix` add this line to your primary function
```nix
nix.settings.experimental-featurs = [ "nix-command" "flakes" ];
```

##### Other distros, with home manager

In your home-manager config add these lines
```nix
nix = {
    package = pkgs.nix;
    settings.experimental-featurs = [ "nix-command" "flakes" ];
};
```

##### Other distros, without home manager

Add this to your `nix.conf` (`/etc/nix/nix.conf` or `/.config/nix/nix.config`)
```
experimental-features = nix-command flakes
```

#### Building and Running

It's suggested to do `nix run`, for that will build and run it but if you wish to build it with
nix build and run it manually you can

`nix build` should build an excecutable in `result/bin/game`, run it with `./result/bin/game`
