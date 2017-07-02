class CpuMemory

  def initialize(@mapper : Mapper, @ppu : Ppu, @control_pad : ControlPad)
    @cpu_ram = CpuRam.new
  end

  def read(address)
    case
    when address < 0x2000
      @cpu_ram.peek(address)
    when address < 0x4000
      @ppu.read_register((address - 0x2000) % 8)
    when address == 0x4016
      @control_pad.read
    when address >= 0x8000
      @mapper.read_prg(address - 0x8000)
    else
      0_u8
      # raise "Can't read memory address: 0x#{address.to_s(16)}"
    end
  end

  def read2(address)
    a = read(address).to_u16
    b = read(address + 1).to_u16
    (b << 8) | a
  end

  def read2_with_bug(address)
    # take hi part and wrap around low part
    bugged_address = (address & 0xFF00) | ((address & 0x00FF).to_u8 + 1).to_u16
    a = read(address).to_u16
    b = read(bugged_address).to_u16
    (b << 8) | a
  end

  def write(address, value)
    case
    when address < 0x2000
      @cpu_ram.poke(address, value)
    when address < 0x4000
      @ppu.write_register((address - 0x2000) % 8, value)
    when address == 0x4014
      @ppu.dma_address = value
    when address == 0x4016
      @control_pad.write value
    when address >= 0x8000
      @mapper.write_prg(address - 0x8000, value)
    # else
      # raise "Can't write memory address: 0x#{address.to_s(16)}"
    end
  end

end
