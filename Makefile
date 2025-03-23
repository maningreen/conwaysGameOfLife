GHC = ghc

SRC = $(wildcard src/*.hs)

OBJS = $(SRC:src/%.hs=build/%.o)

LDFLAGS = -Wall -package hscurses -package random

TARGET = game

main: $(OBJS)
	$(GHC) $(OBJS) -outputdir build/ -o build/$(TARGET) $(LDFLAGS)

build/%.o : src/%.hs
	$(GHC) -c -o $@ $< -outputdir build/

clean:
	rm build/*
