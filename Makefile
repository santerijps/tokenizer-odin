EXT :=

ifeq ($(OS),Windows_NT)
	EXT = .exe
endif

all: cli

cli: cli/cli.odin bin
	odin build cli -o:speed -out:bin/tokenizer$(EXT)

bin: cli/cli.odin
	mkdir bin
