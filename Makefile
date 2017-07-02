.PHONY: all main_sdl
all: main_sdl

main_sdl:
	crystal build main_sfml.cr -o nes --release
