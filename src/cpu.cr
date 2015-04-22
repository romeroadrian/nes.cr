require "./cpu_ram"

class Cpu
  def initialize(@rom)
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

    @ram = CpuRam.new

    init
  end

  def read(address)
    case
    when address < 0x2000
      @ram.peek(address)
    when address >= 0x8000
      @rom.readPRG(address - 0x8000)
    else
      0
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
      @ram.poke(address, value)
    end
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
    else
      raise "Missing instruction: 0x#{instruction.to_s(16)}"
    end
  end

  private def init
    # 6502 begins execution at u16 in 0xFFFC
    @pc = read2(0xFFFC)
  end

  private def sei
    @i = 1_u8
  end

  private def cld
    @d = 0_u8
  end

  private def ldxImmediate
    @x = read(@pc)
    @pc += 1
    # Z and N
    @z = @x & 0x1
    @n = (@x >> 7) & 0x1
  end

  private def txs
    @sp = @x
  end

  private def ldaAbsolute
    @a = read(read2(@pc))
    @pc += 2
    @z = @a & 0x1
    @n = (@a >> 7) & 0x1
  end

  private def bpl
    offset = read(@pc)
    @pc += 1
    if @n == 0
      @pc += offset - 0x80 # relative treats offsets as signed bytes
    end
  end

  # stack is at  $0100 and $01FF
  # SP is an offset to $0100

  # flags
  # 7 6 5 4 3 2 1 0
  # N V   B D I Z C

  # opcodes: 151 possible of 256 (8 bits)
end
