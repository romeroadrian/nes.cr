require "./src/rom"
require "./src/cpu"
require "./src/memory"

if ARGV.length > 0
  rom = Rom.from_file ARGV[0]
  memory = Memory.new rom
  c = Cpu.new memory

  p "Valid header: #{rom.valid_header?}"

  p "PRG banks: #{rom.prg_banks}"
  p "CHR banks: #{rom.chr_banks}"

  p "Has trainer: #{rom.has_trainer?}"

  while true
    c.step
  end
end
