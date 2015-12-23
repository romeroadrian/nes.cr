# nes.cr

## Prerequisites

* libSDL

### Installation on OSX

You can install libSDL via homebrew:

```
brew install sdl
```

## Compile

```
make
```

## Run

```
./nes rom_file.nes
```

## Controls:

* Arrows: arrows
* Z: A
* X: B
* O: Start
* P: Select

## TODO

* Audio (implement Nes APU)
* More mappers (currently NROM and UNROM are supported)

## Issues

Some graphical issues (vblank handling in PPU?)
