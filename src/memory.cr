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

  def read2_with_bug(address)
    # take hi part and wrap around low part (ie )
    bugged_address = (address & 0xFF00) | ((address & 0x00FF).to_u8 + 1).to_u16
    a = read(address).to_u16
    b = read(bugged_address).to_u16
    (b << 8) | a
  end

  def write(address, value)
    case
    when address < 0x2000
      @cpu_ram.poke(address, value)
    end
  end

end
