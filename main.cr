require "./src/rom"

if ARGV.length > 0
  r = Rom.from_file ARGV[0]

  p "Valid header: #{r.valid_header?}"

  p "PRG banks: #{r.prg_banks}"
  p "CHR banks: #{r.chr_banks}"

  p "Has trainer: #{r.has_trainer?}"
end
