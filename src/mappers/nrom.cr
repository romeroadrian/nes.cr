class Nrom < Mapper
  def initialize(@rom : Rom)
  end

  def read(address)
    case
    when address < 0x2000
      @rom.read_chr(address)
    when address >= 0xC000
      @rom.read_prg(address - 0xC000)
    when address >= 0x8000
      @rom.read_prg(address - 0x8000)
    else
      raise "Error reading Nrom mapper address #{address}"
    end
  end

  def write(address, value)
    case
    when address < 0x2000
      @rom.write_chr(address, value)
    end
  end
end
