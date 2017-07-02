class CpuRam
  def initialize
    @mem = Array(UInt8).new(0x800, 0_u8)
  end

  def peek(address)
    @mem[address % 0x800]
  end

  def poke(address, value)
    @mem[address % 0x800] = value
  end
end
