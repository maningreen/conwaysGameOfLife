GHC = ghc

SRC = $(wildcard src/*.hs)

OBJS = $(SRC:src/%.hs=build/%.o)

LDFLAGS = -Wall -package hscurses -package random

TARGET = gameOfLife

BUILDDIR = build/

main: $(OBJS) $(BUILDDIR)
	$(GHC) $(OBJS) -outputdir build/ -o build/$(TARGET) $(LDFLAGS)

$(BUILDDIR)%.o : src/%.hs $(BUILDDIR)
	$(GHC) -c -o $@ $< -outputdir build/

$(BUILDDIR):
	mkdir -p build

clean:
	rm build/*


