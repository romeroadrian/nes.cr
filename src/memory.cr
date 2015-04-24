class Memory

  def initialize(@rom)
    @cpu_ram = CpuRam.new
  end

  def read(address)
    case
    when address < 0x2000
      @cpu_ram.peek(address)
    when address >= 0x8000
      @rom.readPRG(address - 0x8000)
    else
      0_u8
    end
  end

  def read2(address)
    a = read(address).to_u16
    b = read(address + 1).to_u16
    (b << 8) | a
  end

  def write(address, value)
    case
    when address < 0x2000
      @cpu_ram.poke(address, value)
    end
  end

end
