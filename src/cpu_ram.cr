class CpuRam
  def initialize
    @mem = StaticArray(UInt8, 0x800).new { 0_u8 }
  end

  def peek(address)
    @mem[address % 0x800]
  end

  def poke(address, value)
    @mem[address % 0x800] = value
  end
end
