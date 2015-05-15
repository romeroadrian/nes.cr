class Unrom
  def initialize(@rom)
    @low_bank = 0_u32
    @high_bank = (@rom.prg_banks - 1).to_u32
  end

  def read_prg(address)
    index = address >= Rom::PRG_ROM_SIZE ? @high_bank : @low_bank
    offset = address % Rom::PRG_ROM_SIZE
    address = index * Rom::PRG_ROM_SIZE + offset
    @rom.read_prg(address)
  end

  def write_prg(address, value)
    @low_bank = value.to_u32
  end
end
