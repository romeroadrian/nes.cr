require "./cpu_ram"

class Cpu

  @a :: UInt8
  @x :: UInt8
  @y :: UInt8
  @sp :: UInt8
  @pc :: UInt16

  @c :: UInt8
  @z :: UInt8
  @i :: UInt8
  @d :: UInt8
  @b :: UInt8
  @v :: UInt8
  @n :: UInt8

  def initialize(@memory)
    # CPU Registers
    @a = 0_u8     # accumulator 8bits
    @x = 0_u8     # x index 8bits
    @y = 0_u8     # y index 8bits
    @sp = 0_u8    # stack pointer 8bits
    @pc = 0_u16   # program counter 16bits

    # CPU flags
    @c = 0_u8 # C carry flag
    @z = 0_u8 # Z zero flag
    @i = 0_u8 # I interrupt disable flag
    @d = 0_u8 # D decimal mode flag (not used in NES)
    @b = 0_u8 # B break command flag
    @v = 0_u8 # V overflow flag
    @n = 0_u8 # N negative flag (0 = positive, 1 = negative)

    init
  end

  def step
    instruction = read(@pc)
    @pc += 1
    case instruction
    when 0x78
      sei
    when 0xD8
      cld
    when 0xA2
      ldxImmediate
    when 0x9A
      txs
    when 0xAD
      ldaAbsolute
    when 0x10
      bpl
    when 0xA5
      ldaZero
    when 0x4A
      lsrA
    when 0xB0
      bcs
    when 0x4C
      jmpAbsolute
    when 0x20
      jsrAbsolute
    when 0xC5
      cmp_zero
    else
      raise "Missing instruction: 0x#{instruction.to_s(16)}"
    end
  end

  private def init
    # 6502 begins execution at u16 in 0xFFFC
    @pc = read2(0xFFFC)
    # SP starts at 0xFD
    @sp = 0xFD_u8
  end

  private def read(address)
    @memory.read address
  end

  private def read2(address)
    @memory.read2 address
  end

  private def write(address, value)
    @memory.write address, value
  end

  # INSTRUCTIONS

  private def sei
    @i = 1_u8
  end

  private def cld
    @d = 0_u8
  end

  private def ldxImmediate
    @x = read(@pc)
    @pc += 1
    set_ZN(@x)
  end

  private def txs
    @sp = @x
  end

  private def ldaAbsolute
    @a = read(read2(@pc))
    @pc += 2
    set_ZN(@a)
  end

  private def bpl
    offset = read(@pc)
    @pc += 1
    if @n == 0
      @pc += offset - 0x80 # relative treats offsets as signed bytes
    end
  end

  private def ldaZero
    @a = read(read(@pc))
    @pc += 1
    set_ZN(@a)
  end

  private def lsrA
    @c = @a & 0x1
    @a >> 1
    set_ZN(@a)
  end

  private def bcs
    offset = read(@pc)
    @pc += 1
    if @c > 0
      @pc += offset - 0x80 # relative
    end
  end

  private def jmpAbsolute
    @pc = read2(@pc)
  end

  private def jsrAbsolute
    push_stack_2(@pc - 1)
    @pc = read2(@pc)
  end

  private def cmp_zero
    r = @a - read(read(@pc))
    @c = r >= 0 ? 1_u8 : 0_u8
    set_ZN(r)
  end

  # FLAGS

  private def set_ZN(value)
    @z = value # TODO is this ok?
    @n = (value >> 7) & 0x1
  end

  # STACK POINTER

  private def push_stack_2(value)
    a = (value >> 8).to_u8
    b = (value & 0xFF).to_u8
    push_stack a
    push_stack b
  end

  private def push_stack(value)
    write(@sp.to_u16 + 0x100, value)
    @sp -= 1
  end

  private def pop_stack
    @sp += 1
    read(@sp.to_u16 + 0x100)
  end

  private def pop_stack_2
    b = pop_stack.to_u16
    a = pop_stack.to_u16
    (a << 8) | b
  end

  # flags
  # 7 6 5 4 3 2 1 0
  # N V   B D I Z C

  # opcodes: 151 possible of 256 (8 bits)
end
