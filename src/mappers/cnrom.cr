class Cnrom < Mapper

  # CNROM has 32k of CHR (4 banks) and 32k of PRG (2 banks)

  def initialize(@rom : Rom)
    @curent_chr_bank = 0
  end

  def read(address)
    case
    when address < 0x2000
      mapped_address = @curent_chr_bank * 0x2000 + address
      @rom.read_chr(mapped_address)
    when address >= 0xC000
      # Read from PRG second bank
      mapped_address = 0x4000 + (address - 0xC000)
      @rom.read_prg(mapped_address)
    when address >= 0x8000
      # Read from PRG first bank
      mapped_address = address - 0x8000
      @rom.read_prg(mapped_address)
    when address >= 0x6000
      mapped_address = address - 0x6000
      @rom.read_sram(mapped_address)
    else
      raise "Error reading address #{address} for CNROM mapper"
    end
  end

  def write(address, value)
    case
    when address < 0x2000
      mapped_address = @curent_chr_bank * 0x2000 + address
      @rom.write_chr(mapped_address, value)
    when address >= 0x8000
      @curent_chr_bank = (value & 3).to_i
    when address >= 0x6000
      mapped_address = address - 0x6000
      @rom.write_sram(mapped_address, value)
    end
  end
end
