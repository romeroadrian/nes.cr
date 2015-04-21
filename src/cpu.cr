class Cpu
  def initialize
    @a = 0_u8     # accumulator 8bits
    @x = 0_u8     # x index 8bits
    @y = 0_u8     # y index 8bits
    @sp = 0_u8    # stack pointer 8bits
    @pc = 0_u16   # program counter 16bits
    @flags = 0_u8 # CPU flags 8bits
  end

  # stack is at  $0100 and $01FF
  # SP is an offset to $0100

  # flags
  # 7 6 5 4 3 2 1 0
  # N V   B D I Z C

  # opcodes: 151 possible of 256 (8 bits)
end
