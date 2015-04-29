require "./src/nes"
require "crsfml"

if ARGV.length > 0
  nes = Nes.new ARGV[0]

  p "Valid header: #{nes.rom.valid_header?}"

  p "PRG banks: #{nes.rom.prg_banks}"
  p "CHR banks: #{nes.rom.chr_banks}"

  p "Has trainer: #{nes.rom.has_trainer?}"

  p "Mapper number: #{nes.rom.mapper_number}"

  nes.run

  # window = SF::RenderWindow.new(SF.video_mode(800, 600), "NES")
end
