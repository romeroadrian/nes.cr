class Unrom < Mapper
  @low_bank : UInt32
  @high_bank : UInt32

  def initialize(@rom : Rom)
    @low_bank = 0_u32
    @high_bank = (@rom.prg_banks - 1).to_u32
  end

  def read(address)
    case
    when address < 0x2000
      @rom.read_chr(address)
    when address >= 0x8000
      address = address - 0x8000
      index = address >= Rom::PRG_ROM_SIZE ? @high_bank : @low_bank
      offset = address % Rom::PRG_ROM_SIZE
      address = index * Rom::PRG_ROM_SIZE + offset
      @rom.read_prg(address)
    else
      raise "Error reading Nrom mapper address #{address}"
    end
  end

  def write(address, value)
    case
    when address < 0x2000
      @rom.write_chr(address, value)
    when address >= 0x8000
      @low_bank = value.to_u32
    else
      raise "Error writing Unrom mapper address #{address}"
    end
  end
end
