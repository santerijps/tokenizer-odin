EXT :=

ifeq ($(OS),Windows_NT)
	EXT = .exe
endif

debug: cli/cli.odin bin
	odin build cli -o:none -debug -out:bin/tokenizer$(EXT)

release: cli/cli.odin bin
	odin build cli -o:speed -out:bin/tokenizer$(EXT)

bin: cli/cli.odin
	mkdir bin
